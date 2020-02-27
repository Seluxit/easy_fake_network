module Core_Test
  class Output
    def initialize(code, result, headers: {})
      @code = code
      @result = result
      @headers = headers
    end

    attr_reader :code, :result, :headers

    def dig(*args)
      case args[0]
      when 0
        return @code
      when 1
        return @result if args[1..-1].empty?
        @result.dig(*args[1..-1]) rescue @result
      else
        @result.dig(*args) rescue @result
      end
    end

    def [](arg)
      case arg
      when 0
        @code
      when 1
        @result
      else
        @result[arg]
      end
    end
  end
end
