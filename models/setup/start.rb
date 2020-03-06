require_relative "gems"
require_rel "../utility"
require_relative "methods"
require_rel "../../models"
require_rel "../../mockers"

yaml = Core_Lib::Yaml.fetch_yaml_file("#{__dir__}/../../config.yml")
$basic = Core_Lib::Obj.symbolize_keys_deep(yaml)
@session = Core_Test::Session.new(username: $basic[:username], password: $basic[:password])
$basic[:endpoint] = $basic[:old_endpoint] ? "/services/" : "/services/2.0/"
