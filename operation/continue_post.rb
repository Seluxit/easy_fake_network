module Script
  class Network
    def continue_post
      return unless @operations.include?("continue_post")

      structure = Core_Lib::Obj.load(File.read("#{__dir__}/../structure.json"))
      body = Core_Lib::DeepClone.clone(structure)
      populate_body_id(body, $basic[:network][:id])
      iot = Core_Test::Iot.new(id: $basic[:network][:id])
      iot.run

      Thread.new do
        loop do
          iot.request(:post, "/services/2.0/network", body: body)
        end
      end
    end
  end
end
