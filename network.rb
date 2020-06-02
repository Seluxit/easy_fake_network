require_relative "models/setup/start"

module Script
  class Network
    def initialize(operations)
      @operations = operations
      @operations = ["run", "listen"] if @operations.empty?
      @session = Core_Test::Session.new(**$basic[:authentication])
      @iots = {}
      @thread = Thread.pool(10, 20)
    end

    def start
      continue_post
      create
      run
      delete
      listen
      loop{} if !(["listen", "run", "continue_post"] & @operations).empty?
    end
  end
end

Script::Network.new(ARGV).start
