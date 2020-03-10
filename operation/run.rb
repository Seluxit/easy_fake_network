module Script
  class Network
    def run
      return unless @operations.include?("run")

      @values_id = @session.get("#{$basic[:endpoint]}value?parent_parent_name=#{$basic[:name_network]}").result[:id]

      @values = {}

      loop do
        value_id = @values_id.sample
        retrieve_logic(value_id)
        @values[value_id][:iot].run if @values[value_id][:is_iot]
        control(value_id)
        report(value_id)
        @values[value_id][:iot].stop if @values[value_id][:is_iot]
      end
    end

    def report(value_id)
      return if @values[value_id][:report].nil?

      if @values[value_id][:is_iot]
        @values[value_id][:iot].request(:patch, "/services/2.0/state/#{@values[value_id][:report]}",
          {data: return_data(value_id)})
      else
        @session.patch("#{$basic[:endpoint]}state/#{@values[value_id][:report]}",
          {data: return_data(value_id)})
      end
    end

    def control(value_id)
      return if @values[value_id][:control].nil?

      @values[value_id][:iot].run if @values[value_id][:is_iot]
      @session.patch("#{$basic[:endpoint]}state/#{@values[value_id][:control]}",
        {data: return_data(value_id)})
      if @values[value_id][:is_iot]
        @values[value_id][:iot].receive_data
      end
    end

    def retrieve_logic(value_id)
      return if @values.key?(value_id)

      value = @session.get("#{$basic[:endpoint]}value/#{value_id}?expand=1&verbose=true")
      if value.code != 200 || value[:permission] == "none"
        @values_id -= [value_id]
        return nil
      end

      if value.has_key?(:number)
        @values[state_id] = {type: :number, info: value[:number]}
      elsif value.has_key?(:string)
        @values[state_id] = {type: :string, info: value[:string]}
      elsif value.has_key?(:blob)
        @values[state_id] = {type: :blob, info: value[:blob]}
      elsif value.has_key?(:xml)
        @values[state_id] = {type: :xml, info: value[:xml]}
      end
      state_control_id = value[:state].find{|s| s[:type] == "Control"}
      @values[value_id][:control] = state_control_id unless state_control_id.nil?
      state_report_id = value[:state].find{|s| s[:type] == "Report"}
      @values[value_id][:report] = state_report_id unless state_report_id.nil?
      @values[value_id][:is_iot] = value[:meta][:iot]

      if @values[value_id][:is_iot]
        network_id =
          @session.get("#{$basic[:endpoint]}network?expand=1&child_child_meta.id=#{value_id}")[:id][0]
        iot = @iots[network_id]
        if iot.nil?
          @iots[network_id] = Core_Test::Iot.new(id: network_id)
        end
        @values[value_id][:iot] = @iots[network_id]
      end
    end

    def return_data(value_id)
      case @values[value_id][:type]
      when :number
        rand(@values[value_id][:info][:min].to_i..@values[value_id][:info][:max].to_i).to_s
      when :string
        FFaker::DizzleIpsum.paragraph
      when :blob
        FFaker::DizzleIpsum.characters
      when :xml
        "<string>#{FFaker::DizzleIpsum.paragraph}</string>"
      end
    end
  end
end
