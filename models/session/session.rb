module Core_Test
  class Session
    X_SESSION = "X-Session"

    def initialize(username: nil, password: nil, session_id: nil, rest: nil)
      @test = test
      @rest = rest || Core_Test::Rest.new
      @headers = {}
      @username = username
      @password = password
      if !session_id.nil?
        @headers[X_SESSION] = session_id
        unless verify
          puts "Session not defined"
          abort
        end
      elsif !username.nil?
        recreate
        unless verify
          puts "Session not defined"
          abort
        end
      else
        puts "No username or password defined"
        abort
      end
    end

    attr_reader :username, :password, :installation_id
    attr_accessor :test, :headers

    def verify
      response = @rest.request(:get, "/services/2.1/session/#{@headers[X_SESSION]}",
        headers: @headers)
      response.code == 200
    end

    def recreate
      body = {username: @username, password: @password}
      response = @rest.request(:post, "/services/2.1/session", body: body)
      @headers[X_SESSION] = response&.dig(1, :meta, :id)
    end

    def delete_session
      @test.sessions -= [self]
      request(:delete, "/services/2.1/session/#{@headers[X_SESSION]}")
    end

    def user_id
      return @user_id if UUID.validate(@user_id)

      response = request(:get, "/services/2.1/user/me")
      @user_id = response.dig(1, :meta, :id)
      @user_id
    end

    def create_network(body: nil)
      body ||= Core_Test::Mocker.network
      response = request(:post, "#{$basic[:endpoint]}network", body: body)
      response&.dig(1, :meta, :id)
    end
  end
end
