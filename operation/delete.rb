module Script
  class Network
    def delete
      return unless @operations.include?("delete")
      @session.delete("#{$basic[:endpoint]}network?this_name=#{$basic[:name_network]}")
    end
  end
end
