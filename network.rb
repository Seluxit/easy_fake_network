require_relative "models/setup/start"

operations = ARGV
operations = ["create", "run"] if operations.empty?

if operations.include?("create")
  network_id = @session.create_network
  name = $basic[:name_network] + " " + rand(100000).to_s
  @session.patch("#{$basic[:endpoint]}network/#{network_id}", {name: name})
end

if operations.include?("run")
  hash = {}
  values = @session.get("#{$basic[:endpoint]}value?parent_parent_name=#{$basic[:name_network]}&expand=0").result
  values&.each do |value|
    value[:state]&.each do |state_id|
      if value.has_key?(:number)
        hash[state_id] = {type: :number, info: value[:number]}
      elsif value.has_key?(:string)
        hash[state_id] = {type: :string, info: value[:string]}
      elsif value.has_key?(:blob)
        hash[state_id] = {type: :blob, info: value[:blob]}
      elsif value.has_key?(:xml)
        hash[state_id] = {type: :xml, info: value[:xml]}
      end
    end
  end

  loop do
    state_id = hash.keys.sample
    if state_id.nil?
      puts "No state found for this network, run this script again"
      abort
    end
    data ||= case hash[state_id][:type]
    when :number
      rand(hash[state_id][:info][:min].to_i..hash[state_id][:info][:max].to_i).to_s
    when :string
      FFaker::DizzleIpsum.paragraph
    when :blob
      FFaker::DizzleIpsum.characters
    when :xml
      "<string>#{FFaker::DizzleIpsum.paragraph}</string>"
    end
    @session.patch("#{$basic[:endpoint]}state/#{state_id}", {data: data})
    sleep(rand(0..10)*$basic[:rate])
  end
end

if operations.include?("delete")
  @session.delete("#{$basic[:endpoint]}network?this_name=#{$basic[:name_network]}")
end
