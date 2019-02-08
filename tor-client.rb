class Tor::HTTP
  def self.post_body(uri_or_host, post_body = "", path = nil, port = nil)
    res, host = "", nil
      if path
        host = uri_or_host
      else
        host = uri_or_host.host
        port = uri_or_host.port
        path = uri_or_host.request_uri
      end

      start_params = start_parameters(uri_or_host, host, port)
      start_socks_proxy(start_params) do |http|
        request = Net::HTTP::Post.new(path)
        request.body = post_options
        Tor.configuration.headers.each do |header, value|
          request.delete(header)
          request.add_field(header, value)
        end
        res = http.request(request)
      end
      res
  end
end

class TorClient < TorControl::Controller
  def get(*args)
    if connected? then
      Tor::HTTP.get(*args)
    else
      "Error: Not connected to tor!"
    end
  end

  def post(*args)
    if connected? then
      Tor::HTTP.post(*args)
    else
      "Error: Not connected to tor!"
    end
  end

  def signal(name)
    send_command(:signal, name)
    read_reply
  end

  # Gives a guess of current computer external address
  def address
    send_command(:getinfo, 'address')
    reply = read_reply.split('=').last
    read_reply # skip "250 OK"
    reply
  end

  # Current output node address
  # Powered by ipify.org
  def public_address
    get(URI("https://api.ipify.org/")).body
  end

  # Current output node address
  # WARNING: Not always working correctly (maybe the output isn't updated instantly?)
  def output_address
    send_command(:getinfo, 'circuit-status')
    read_reply # "250+circuit-status="
    circuit = read_reply # First BUILT circuit is currently being used
    until circuit =~ / BUILT / || circuit == "250 OK"
      circuit = read_reply
    end
    until circuit == "250 OK" || read_reply == "250 OK" do end # The other circuits are not important

    /\$(?<nodeid>\h+)\~\w+ BUILD_FLAGS/ =~ circuit # Select last node id (exit node)
    send_command(:getinfo, 'ns/id/'+nodeid)
    read_reply # "250+ns/id/[nodeid]="
    /(?<ip>\d+\.\d+\.\d+\.\d+)/ =~ read_reply
    until read_reply == "250 OK" do end # The other info is not important
    ip
  end

  # NEWNYM:
  # Switch to clean circuits, so new application requests
  # don't share any circuits with old ones.  Also clears
  # the client-side DNS cache.  (Tor MAY rate-limit its
  # response to this signal.)
  def new_session
    signal("NEWNYM")
  end
end
