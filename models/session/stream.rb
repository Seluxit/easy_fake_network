module Core_Test
  class Session
    def stream(id: nil, subscriptions: [], ignore: nil, version: "2.1", full: true)
      if id.nil?
        url = "/services/#{version}/websocket/open?X-Session=#{@headers[X_SESSION]}&subscription=[#{subscriptions.join(",")}]"
        url += "&ignore=[#{ignore.join(",")}]" unless ignore.nil?
      else
        url = "/services/#{version}/websocket/#{id}?X-Session=#{@headers[X_SESSION]}"
      end
      url += "&full=false" unless full
      Thread.new do
        @rest.websocket(url, @stream_output)
      end
      sleep(0.5)
    end

    def generic_stream(url, add_session: true)
      if add_session
        url += url.include?("?") ? "&X-Session=#{@headers[X_SESSION]}" :
          "?X-Session=#{@headers[X_SESSION]}"
      end
      Thread.new do
        @rest.websocket(url, @stream_output)
      end
    end

    def stream_wait(*args, &block)
      args[0] ||= {}
      args[0][:interval] ||= 0.5
      @test.wait(*args) do
        @stream_output.any? do |t|
          block.call(t)
        end
      end
    end

    def stream_stop
      @stream_output << "STOP"
      sleep(0.5)
    end
  end
end
