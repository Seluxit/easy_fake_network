module Core_Test
  class Session
    def code
      @rest.code
    end

    def result
      @rest.result
    end

    def get(url, *args)
      request(:get, url, *args)
    end

    def head(url, *args)
      request(:head, url, *args)
    end

    def post(url, body, *args)
      args[0] ||= {}
      args[0][:body] = body
      request(:post, url, *args)
    end

    def patch(url, body, *args)
      args[0] ||= {}
      args[0][:body] = body
      request(:patch, url, *args)
    end

    def put(url, body, *args)
      args[0] ||= {}
      args[0][:body] = body
      request(:patch, url, *args)
    end

    def delete(url, *args)
      request(:delete, url, *args)
    end

    def request(*args)
      headers = args.dig(2, :headers) || {}
      args[2] ||= {}
      args[2][:headers] = @headers.merge(headers)
      @rest.request(*args)
    end
    alias send request
  end
end
