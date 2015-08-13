class PkMb::Stub::TcpResponse < PkMb::Stub::Response
  def self.create(data='')
    payload = {}
    payload[:data] = data unless data.empty?

    data = {is: payload}
    new(data)
  end
end
