require_relative "models/setup/start"

module Script
  class Network
    def initialize(operations)
      @operations = operations
      @operations = ["run", "listen"] if @operations.empty?
      @session = Core_Test::Session.new(**$basic[:authentication])
      @iots = {}
    end

    def start
      create
      run
      delete
      listen
      loop{} if @operations.include?("listen") || @operations.include?("run")
    end
  end
end

Script::Network.new(ARGV).start
