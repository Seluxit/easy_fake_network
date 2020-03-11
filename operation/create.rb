module Script
  class Network
    def create
      return unless @operations.include?("create")
      puts "Start creation".blue

      if $basic[:network][:use_structure]
        structure = File.read("#{__dir__}/../structure.json") rescue Core_Test::Mocker.network
      end

      puts "Creation of #{$basic[:network][:number]} networks"

      $basic[:network][:number].times do |t|
        if structure.nil?
          body = Core_Test::Mocker.network
        else
          body = Core_Lib::DeepClone.clone(structure)
        end

        if $basic[:iot][:active]
          puts "Creating iot network"
          iot = Core_Test::Iot.new.create(@session)
          iot.run
          populate_body_id(body, iot.id)
          body[:name] = $basic[:network][:name] + " " + rand(100000).to_s
          iot.request(:post, "/services/2.0/network", body: body)
          @session.post("/services/2.0/network/#{iot.id}", {})
          iot.stop
          puts "Iot network #{body[:name]} - #{iot.id} created".green
        else
          puts "Creating network"
          body[:name] = $basic[:network][:name] + " " + rand(100000).to_s
          @session.post("#{$basic[:endpoint]}network", body)
          puts "Network #{body[:name]} - #{iot.id} created".green
        end
      end
    end

    def populate_body_id(body, id=nil)
      body[:meta] ||= {}
      body[:meta][:id] = id || SecureRandom.uuid
      [:device, :value, :state, :status].each do |k|
        next unless body[k].is_a?(Array)
        body[k].each do |v|
          populate_body_id(v)
        end
      end
    end
  end
end
