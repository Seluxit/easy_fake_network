module Script
  class Network
    def delete
      return unless @operations.include?("delete")
      puts "Start deletion".blue
      
      @session.delete("#{$basic[:endpoint]}network?this_name=#{$basic[:network][:name]}")
      puts "Deletion successful".green
    end
  end
end
