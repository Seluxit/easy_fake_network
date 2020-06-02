require_relative "gems"
require_rel "../utility"
require_relative "methods"
require_rel "../../models"
require_rel "../../mockers"
require_rel "../../operation"

default = Core_Lib::Yaml.fetch_yaml_file("#{__dir__}/../../default.yml")
config = Core_Lib::Yaml.fetch_yaml_file("#{__dir__}/../../config.yml")
config = Core_Lib::Obj.recursive_merge(default, config)
$basic = Core_Lib::Obj.symbolize_keys_deep(config)
$basic[:endpoint] = $basic[:old_endpoint] ? "/services/" : "/services/2.0/"
$basic[:network] ||= {}
$basic[:network][:id] = ENV["NETWORK_ID"]
