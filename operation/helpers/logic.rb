module Script
  class Network
    def retrieve_logic(value_id)
      @values ||= {}
      @states ||= {}
      return if @values.key?(value_id)

      value = @session.get("#{$basic[:endpoint]}value/#{value_id}?expand=1&verbose=true")
      if value.code != 200 || value.result[:permission] == "none"
        @values_id -= [value_id]
        return
      end

      value = value.result
      if value.key?(:number)
        @values[value_id] = {type: :number, info: value[:number]}
      elsif value.has_key?(:string)
        @values[value_id] = {type: :string, info: value[:string]}
      elsif value.has_key?(:blob)
        @values[value_id] = {type: :blob, info: value[:blob]}
      elsif value.has_key?(:xml)
        @values[value_id] = {type: :xml, info: value[:xml]}
      end
      @values[value_id][:name] = value[:name]

      state_control_id = value[:state].find{|s| s[:type] == "Control"}&.dig(:meta, :id)
      unless state_control_id.nil?
        @values[value_id][:control] = state_control_id
        @states[state_control_id] = value_id
      end
      state_report_id = value[:state].find{|s| s[:type] == "Report"}&.dig(:meta, :id)
      unless state_report_id.nil?
        @values[value_id][:report] = state_report_id
        @states[state_report_id] = value_id
      end
      @values[value_id][:is_iot] = value[:meta][:iot]

      if @values[value_id][:is_iot]
        network_id =
          @session.get("#{$basic[:endpoint]}network?child_child_meta.id=#{value_id}").result[:id][0]
        iot = @iots[network_id]
        if iot.nil?
          @iots[network_id] = Core_Test::Iot.new(id: network_id)
        end
        @values[value_id][:iot] = @iots[network_id]
      end
      @values[value_id]
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
