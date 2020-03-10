module Script
  class Network
    def create
      return unless @operations.include?("create")

      if $basic[:network][:use_structure]
        structure = File.read("#{__dir__}/../structure.json") rescue Core_Test::Mocker.network
      end

      $basic[:network][:number].times do |t|
        if structure.nil?
          body = Core_Test::Mocker.network
        else
          body = Core_Lib::DeepClone.clone(structure)
        end

        if $basic[:iot][:active]
          iot = Core_Test::Iot.new.create
          iot.run
          populate_body_id(body, iot.id)
          iot.request(:post, "/services/2.0/network", body: body)
          @session.post("/services/2.0/network/#{iot.id}", {})
          iot.stop
        else
          body[:name] = $basic[:name_network] + " " + rand(100000).to_s
          @session.post("#{$basic[:endpoint]}network", body)
        end
      end
    end

    def populate_body_id(body, id=nil)
      body[:meta] ||= {}
      body[:meta][:id] = id || SecureRandom.uuid
      [:device, :value, :state, :status].each do |k|
        body[k]&.each do |v|
          populate_body_id(v)
        end
      end
    end
  end
end
