def get(url, args = {})
  @session.request(:get, url, options: args)
end

def head(url, args = {})
  @session.request(:head, url, options: args)
end

def post(url, data, args = {})
  @session.request(:post, url, body: data, options: args)
end

def patch(url, data, args = {})
  @session.request(:patch, url, body: data, options: args)
end
def put(url, data, args = {})
  @session.request(:put, url, body: data, options: args)
end

def delete(url, args = {})
  @session.request(:delete, url, options: args)
end
