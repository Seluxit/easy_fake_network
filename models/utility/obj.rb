module Core_Lib
  module Obj
    def self.remove_nil_element(hash)
      case hash
      when Hash
        hash.compact!
        hash.each_value{|v| remove_nil_element(v)}
      when Array
        hash.compact!
        hash.each{|v| remove_nil_element(v)}
      end
      hash
    end

    def self.load(hash, symbol_keys: true)
      return hash unless hash.is_a?(String)
      Oj.load(hash, mode: :json, symbol_keys: symbol_keys)
    end

    def self.dump(hash)
      Oj.dump(hash, use_as_json: true, mode: :json)
    rescue StandardError => e
      Core_Lib::Log.error("WRONG HASH: #{hash}")
      Raven.capture_exception(e, extra: {hash: hash})
      return hash.to_s
    end

    def self.symbolize_keys_deep(hash)
      load(dump(hash))
    end
  end
end
