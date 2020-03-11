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

    def self.recursive_merge(hash1, hash2, merge_array: false)
      hash = {}
      keys = hash1.keys | hash2.keys
      keys.each do |key|
        case [!hash1[key].nil?, !hash2[key].nil?]
        when [true, false]
          hash[key] = hash1[key]
        when [false, true]
          hash[key] = hash2[key]
        when [true, true]
          if hash1[key].is_a?(Hash) && hash2[key].is_a?(Hash)
            hash[key] = recursive_merge(hash1[key], hash2[key], merge_array: merge_array)
          elsif hash1[key].is_a?(Array) && hash2[key].is_a?(Array) && merge_array
            hash[key] = hash1[key] | hash2[key]
          else
            hash[key] = hash2[key]
          end
        end
      end
      hash
    end
  end
end
