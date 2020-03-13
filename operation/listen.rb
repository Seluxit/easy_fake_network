module Script
  class Network
    def listen
      return unless @operations.include?("listen")
      puts "Start listening".blue

      iot_ids = @session.get("#{$basic[:endpoint]}value?parent_parent_name=#{$basic[:network][:name]}&parent_parent_meta.iot==bool(true)&this_permission==rw").result[:id]

      iot_ids.each do |value_id|
        v = retrieve_logic(value_id)
        next if v.nil? || v[:iot].running

        puts "Starting network #{v[:iot].id}".magenta unless v[:iot].running
        v[:iot].run
        Thread.new do
          EM::PeriodicTimer.new(1) do
            data = v[:iot].receive_data
            if data != "" &&  data[:method] == "PUT"
              v[:iot].send_result(data[:id], {success: true})
              control_id = data[:params][:url].split("/")[-1]
              value_id = @states[control_id]
              unless value_id.nil?
                report_id = @values[value_id][:report]
                unless report_id.nil?
                  sending_data = data[:params][:data][:data]
                  puts "Data received for network #{v[:iot].id} state #{control_id}".yellow
                  v[:iot].send_data(:patch, "/services/2.0/state/#{report_id}",
                    body: {data: sending_data})
                  puts "Network #{v[:iot].id} answered".green
                end
              end
            end
            v[:iot].clean_data
          end
        end
      end
    end
  end
end
