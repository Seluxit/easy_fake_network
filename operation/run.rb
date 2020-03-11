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
          if @values[value_id][:is_iot] && !@operations.include?("listen") &&
            $basic[:network][:close_connection]
            @values[value_id][:iot].stop
          end
          sleep(rand(0..10)*$basic[:state][:rate])
        end
      end
    end

    def report(value_id)
      return if @values[value_id][:report].nil?


      data = return_data(value_id)
      puts "Sending #{@values[value_id][:name]} report state #{@values[value_id][:report]} of value. Data: #{data}"
      if @values[value_id][:is_iot]
        response = @values[value_id][:iot].request(:patch, "/services/2.0/state/#{@values[value_id][:report]}",
          body: {data: data})
      else
        response = @session.patch("#{$basic[:endpoint]}state/#{@values[value_id][:report]}",
          {data: data})
      end
      if response.code != 200
        puts "Message not sent successfully: #{response.result[:message]}".red
      else
        puts "Message send successfully".green
      end
    end

    def control(value_id)
      return if @values[value_id][:control].nil?

      data = return_data(value_id)
      puts "Sending #{@values[value_id][:name]} control state #{@values[value_id][:control]} of value. Data: #{data}"
      if @values[value_id][:is_iot]
        @values[value_id][:iot].run
        @values[value_id][:iot].clean_data
        response = nil
        @thread.process do
          response = @session.patch("#{$basic[:endpoint]}state/#{@values[value_id][:control]}",
            {data: data})
        end
        sleep(0.5)

        data = @values[value_id][:iot].receive_data
        @values[value_id][:iot].send_result(data[:id], {success: true})

        loop do
          break unless response.nil?
          sleep(0.5)
        end
      else
        response = @session.patch("#{$basic[:endpoint]}state/#{@values[value_id][:control]}",
          {data: data})
      end

      if response&.code != 200
        puts "Message not sent successfully: #{response&.result[:message]}".red
      else
        puts "Message send successfully".green
      end
    end
  end
end
