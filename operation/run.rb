module Script
  class Network
    def run
      return unless @operations.include?("run")
      puts "Start running".blue

      @values_id = @session.get("#{$basic[:endpoint]}value?parent_parent_name=#{$basic[:network][:name]}").result[:id]

      Thread.new do
        loop do
          value_id = @values_id.sample
          retrieve_logic(value_id)
          if @values[value_id][:is_iot]
            @values[value_id][:iot].run
          end
          control(value_id)
          report(value_id)
          if @values[value_id][:is_iot] && !@operations.include?("listen")
            @values[value_id][:iot].stop
          end
          sleep(rand(0..10)*$basic[:state][:rate])
        end
      end
    end

    def report(value_id)
      return if @values[value_id][:report].nil?

      puts "Sending report value #{@values[value_id][:report]}"
      if @values[value_id][:is_iot]
        @values[value_id][:iot].send_data(:patch, "/services/2.0/state/#{@values[value_id][:report]}",
          body: {data: return_data(value_id)})
      else
        @session.patch("#{$basic[:endpoint]}state/#{@values[value_id][:report]}",
          {data: return_data(value_id)})
      end
    end

    def control(value_id)
      return if @values[value_id][:control].nil?

      puts "Sending control value #{@values[value_id][:control]}"
      @values[value_id][:iot].run if @values[value_id][:is_iot]
      @session.patch("#{$basic[:endpoint]}state/#{@values[value_id][:control]}",
        {data: return_data(value_id)})
      if @values[value_id][:is_iot]
        @values[value_id][:iot].receive_data
      end
    end
  end
end
