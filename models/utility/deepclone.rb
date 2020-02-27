module Core_Lib
  class DeepClone
    def self.clone(object)
      case object
      when Array
        object.map{|var| clone(var)}
      when Hash
        object.each_with_object({}) do |(key, var), new_hash|
          if key == :env
            new_hash[key] = var
            next
          end
          new_hash[key] = clone(var)
        end
      when Struct
        temp_class = object.class
        val = object.to_h
        val = clone(val)
        temp_class.new(*val.values)
      else
        object.clone
      end
    end
  end
end
