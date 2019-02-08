require_relative 'init.rb'
require_relative 'tor-client.rb'
require_relative 'veed.rb'

tor = TorClient.connect(:port => 9051)
Veed.use_tor(tor)
Veed.vote
