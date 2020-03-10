module Core_Test
  class Mocker
    def self.network(name: nil, add_id: false)
      devices = $basic[:device][:number] || rand(1..4)
      val = {
        name: name || FFaker::Product.product,
        device: devices.times.map{device(add_id: add_id)}
      }
      val[:meta] = {id: SecureRandom.uuid} if add_id
      val
    end

    def self.device(name: nil, manufacturer: nil, product: nil,
      serial: nil, description: nil, protocol: nil, communication: nil,
      statuses: rand(4), add_id: false)
      values = $basic[:value][:number] || rand(1..4)
      statuses = $basic[:status][:number] || rand(0..4)
      val = {
        name: name || FFaker::Product.product,
        manufacturer: manufacturer || FFaker::Product.brand,
        product: product || FFaker::Product.model,
        serial: serial || FFaker::SSNMX.ssn,
        description: description || FFaker::CheesyLingo.paragraph,
        protocol: protocol || (FFaker::Product.product + "_protocol"),
        communication: communication || "always",
        value: values.times.map{value(add_id: add_id)},
        status: statuses.times.map{status(add_id: add_id)}
      }
      val[:meta] = {id: SecureRandom.uuid} if add_id
      val
    end

    def self.value(type_state: nil, name: nil, type: nil, period: nil, delta: nil,
      permission: nil, status: "ok", min: nil, max: nil, step: nil, unit: nil,
      si_conversion: nil, encoding: nil, xsd: nil, namespace: nil, add_id: false)
      group_permission = $basic[:value][:permission] || ["r", "w", "rw"]
      body = {
        name: name || FFaker::Music.album,
        type: type || FFaker::Music.genre,
        status: status,
        permission: permission || group_permission.sample,
        period: period,
        delta: delta
      }.compact
      type_state ||= [:number, :string, :blob, :xml].sample
      type_state = $basic[:type_data]&.to_sym unless $basic[:type_data].nil?
      body[type_state] = case type_state
      when :number
        min ||= rand(-100..100)
        max ||= min + rand(100)
        {
          min: min,
          max: max,
          step: step || 1,
          unit: unit || FFaker::UnitMetric.temperature_abbr,
          si_conversion: si_conversion
        }.compact
      when :string, :blob
        {
          max: max || rand(100_000),
          encoding: encoding
        }.compact
      when :xml
        {
          xsd: xsd || "<?xml version='1.0' encoding='UTF-8'?> <xsd:schema targetNamespace='test' xmlns:xsd='http://www.w3.org/2001/XMLSchema' elementFormDefault='qualified'> <xsd:element name='test'> <xsd:complexType> <xsd:sequence> <xsd:element name='name' type='xsd:string' minOccurs='1' maxOccurs='1'></xsd:element> <xsd:element name='surname' type='xsd:string' minOccurs='1' maxOccurs='1'></xsd:element> </xsd:sequence> </xsd:complexType> </xsd:element> </xsd:schema>",
          namespace: namespace || "test"
        }
      end
      body[:state] ||= []
      if body[:permission].include?("r")
        body[:state] << state(type: "Report", type_data: type_state, add_id: add_id, min: min, max: max)
      end
      if body[:permission].include?("w")
        body[:state] << state(type: "Control", type_data: type_state, add_id: add_id, min: min, max: max)
      end
      body[:meta] = {id: SecureRandom.uuid} if add_id
      body
    end

    def self.state(timestamp: nil, data: nil, type: nil, type_data: :string,
      add_id: false, min: 0, max: 100)
      data ||= case type_data
      when :number
        rand(min..max).to_s
      when :string
        FFaker::DizzleIpsum.paragraph
      when :blob
        FFaker::DizzleIpsum.characters
      when :xml
        "<string>#{FFaker::DizzleIpsum.paragraph}</string>"
      end
      val = {
        timestamp: timestamp || Time.iso,
        data: data,
        type: type || ["Report", "Control"].sample
      }
      val[:meta] = {id: SecureRandom.uuid} if add_id
      val
    end

    def self.status(message: nil, timestamp: nil, data: nil, level: nil,
      type: nil, add_id: false)
      val = {
        message: message || FFaker::DizzleIpsum.paragraph,
        data: data || FFaker::DizzleIpsum.characters,
        timestamp: timestamp || Time.iso,
        level: level || ["important", "error", "warning", "info", "debug"].sample,
        type: type || [
          "public key", "memory information", "device description",
          "value description", "value", "partner information", "action",
          "calculation", "timer", "calendar", "statemachine", "firmware update",
          "configuration", "exi", "system", "application", "gateway"
        ].sample
      }
      val[:meta] = {id: SecureRandom.uuid} if add_id
      val
    end
  end
end
