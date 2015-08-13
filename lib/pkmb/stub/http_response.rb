class PkMb::Stub::HttpResponse < PkMb::Stub::Response
  def self.create(statusCode=200, headers={}, body='')
    payload = {}
    payload[:statusCode] = statusCode
    payload[:headers] = headers unless headers.empty?
    payload[:body] = body unless body.empty?

    data = {is: payload}
    new(data)
  end
end
