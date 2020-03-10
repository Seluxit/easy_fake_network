require_relative "models/setup/start"

module Script
  class Network
    def initialize(operations)
      @operations = operations
      @operations = ["create", "run"] if @operations.empty?
      @session = Core_Test::Session.new(**$basic[:authentication][:username])
      @iots = {}
    end

    def start
      create
      run
      delete
    end
  end
end
