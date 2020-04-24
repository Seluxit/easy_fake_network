require 'socket'
require 'eventmachine'
require 'fileutils'

require "pry-byebug"

module Core_Test
  class Iot
    ADDR_KEYS = "#{__dir__}/temp_keys"
    ADDR_PRIVATE_KEY = "#{__dir__}/temp_keys/private_key"
    ADDR_CERTIFICATE = "#{__dir__}/temp_keys/certificate"

    class ClientHandler < EM::Connection
      def initialize(id:)
        @id = id
        @data = ""
        @host = $basic[:iot][:host]
        @port = $basic[:iot][:port]
        super
      end

      attr_reader :data

      def connection_completed
        start_tls(private_key_file: "#{ADDR_PRIVATE_KEY}/#{@id}.key",
          cert_chain_file: "#{ADDR_CERTIFICATE}/#{@id}.crt")
      end

      def receive_data(data)
        @data ||= ""
        if data.start_with?("{") || data.start_with?("[")
          @data = data
        else
          @data << data
        end
        data
      end

      def clean_data
        @data = ""
      end

      def ssl_handshake_completed
        puts "Connection establised for network #{@id}".green
      end
    end

    def initialize(id: nil)
      @id = id
      @running = false
    end

    attr_reader :id

    def create(session)
      creator = session.post("/services/2.1/creator", {})
      @id = creator[:network][:id]
      FileUtils.mkdir_p(ADDR_PRIVATE_KEY)
      FileUtils.mkdir_p(ADDR_CERTIFICATE)
      File.write("#{ADDR_PRIVATE_KEY}/#{@id}.key", creator[:private_key])
      File.write("#{ADDR_CERTIFICATE}/#{@id}.crt", creator[:certificate])
      self
    end

    def run
      return if @running
      @running = true
      @client = nil
      @data = {}
      Thread.new do
        EM.run do
          @client = EventMachine.connect($basic[:iot][:host], $basic[:iot][:port], ClientHandler,
            id: @id)
        end
      end
      sleep(0.5)
    end

    def reconnect(close: false)
      if close
        @client.close_connection rescue nil
        sleep(0.1)
      end
      @client.reconnect($basic[:iot][:host], $basic[:iot][:port])
      sleep(0.5)
    end

    attr_reader :id, :creator_id, :bulk, :running
    attr_accessor :test, :client

    def request(*args)
      send_data(*args)
      data = receive_data
      return data if data.is_a?(String) || data.nil?

      if data.key?(:result)
        code = args[0] == :post ? 201 : 200
        Core_Test::Output.new(code, data[:result])
      else
        code = data.dig(:error, :code) || 500
        Core_Test::Output.new(code, data.dig(:error, :data))
      end
    end

    def clean_data
      @client.clean_data
    end

    def clean_bulk
      @bulk = []
    end

    def add_to_bulk(method, url, body: nil, options: nil)
      @bulk ||= []
      @bulk << {
        jsonrpc: "2.0",
        method: method,
        id: SecureRandom.hex,
        params: {
          url: url,
          data: body,
          identifier: options.dig(:identifier),
          trace: options.dig(:trace)
        }.compact
      }
    end

    def send_bulk
      @client.clean_data
      print_on_screen(@bulk, :request)
      @client.send_data(Core_Lib::Obj.dump(@bulk))
      @bulk = []
      data = receive_data
      return data if data.is_a?(String)
      Core_Test::Output.new(0, data)
    end

    def send_data(method, url, body: nil, options: nil)
      @client.clean_data
      hash = {
        jsonrpc: "2.0",
        method: method,
        id: SecureRandom.hex,
        params: {
          url: url,
          data: body,
          identifier: options&.dig(:identifier),
          trace: options&.dig(:trace)
        }.compact
      }
      print_on_screen(hash, :request)
      @client.send_data(Core_Lib::Obj.dump(hash))
    end

    def send_result(id, result)
      @client.clean_data
      hash = {
        jsonrpc: "2.0",
        id: id,
        result: result
      }
      print_on_screen(hash, :result)
      @client.send_data(Core_Lib::Obj.dump(hash))
    end

    def send_error(id, code, message="", data=nil)
      @client.clean_data
      hash = {
        jsonrpc: "2.0",
        id: id,
        error: {
          code: code,
          message: message,
          data: data
        }.compact
      }
      print_on_screen(hash, :error)
      @client.send_data(Core_Lib::Obj.dump(hash))
    end

    def receive_data(repeat: 10)
      data = nil
      repeat.times do |t|
        data = @client.data
        data = Core_Lib::Obj.load(data) rescue data
        break if data != ""
        sleep(0.5) if repeat > 1
      end
      print_on_screen(data, :response)
      data
    end

    def print_on_screen(hash, type)
      return unless $basic[:verbose]
      print "\n === RPC #{type.to_s.upcase} #{@id} ===\n".yellow
      ap hash, indent: -2
      print " === END #{type.to_s.upcase} #{@id} ===\n".yellow
    end

    def stop(delete_certificate: true)
      @client.close_connection rescue nil
      @running = false
      puts "Connection closed for network #{@id}".red
      sleep(0.1)
    end

    def delete_certificate
      FileUtils.rm_rf(ADDR_KEYS)
    end
  end
end
