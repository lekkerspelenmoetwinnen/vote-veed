module Veed
  def self.use_tor(tor)
    @@tor = tor
  end
  def self.vote
    @@tor.new_session
    puts "Voting with IP address #{@@tor.public_address}, your computers own external address is #{@@tor.address}"
    headers = generate_headers
    headers.merge!("Cookie" => @@tor.get(URI("https://stem.veed.nl/"),headers)['set-cookie'].split('; ')[0])
    @@tor.post(URI("https://stem.veed.nl/"),headers)
  end
  # Attempt to generate believable headers
  def generate_headers
    {
      accept => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      accept-encoding => "gzip, deflate, br",
      accept-language => "nl,en-US;q=0.7,en;q=0.3",
      user-agent => "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:63.0) Gecko/20100101 Firefox/63.0" #Firefox 63 win 10. Add other browsers later
    }
  end
end
