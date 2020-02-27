module Core_Test
  class Rest
    def initialize(host: $basic[:host], verbose: $basic[:verbose])
      @host    = host
      @options = {
        headers: {"Content-Type" => "application/json", "Accept" => "application/json"},
        timeout: 60,
        format: :plain
      }
      @verbose = verbose
    end

    attr_accessor :verbose, :code, :result

    def request(method, path, body: nil, headers: {}, verbose: @verbose, options: {})
      # Parse request

      options.merge!(Core_Lib::DeepClone.clone(@options)).compact!
      case body
      when nil
        # Do nothing
      when String
        options[:body] = body
      else
        options[:body] = Core_Lib::Obj.dump(body)
      end

      options[:headers].merge!(headers).compact!
      path = "#{@host}#{path}"
      method = method.to_s.downcase.to_sym

      # Do request
      path = URI.encode(path)
      response = HTTParty.send(method, path, options)

      # Parse response
      @code = response.code
      begin
        @result = method == :head ? nil : Core_Lib::Obj.load(response.body)
      rescue StandardError
        @result = response.body
      end
    rescue StandardError => e
      @code = :error
      @result = {class_error: e.class, message: e.message}
    ensure
      # Print response
      print_on_screen(method, path, body, verbose)

      # Send on nats
      # send_on_queue(method, path, options, code, result)
      return Output.new(@code, @result, headers: response&.headers)
    end

    def print_on_screen(method, path, body, verbose)
      return unless verbose

      id = rand(1000)

      print "\n === REQUEST #{id} ===\n".yellow
      print "#{method.to_s.upcase} #{path}\n".blue
      ap body, indent: -2 unless body.nil?

      print "\n === RESPONSE #{id} ===\n".yellow
      print "#{"CODE:".yellow} #{@code.to_s.blue}\n"
      ap @result, indent: -2 unless @result.nil?
      print "\n === END #{id} ===\n".yellow
    end
  end
end
