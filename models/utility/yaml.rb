module Core_Lib
  module Yaml
    def self.fetch_yaml_file(dir, ok_false: false)
      yaml = YAML.load_file(dir)
      if yaml == false
        return {} if ok_false

        Core_Lib::Log.error("File #{dir} not well written")
        abort
      end
      yaml
    rescue Errno::ENOENT
      {}
    end
  end
end
