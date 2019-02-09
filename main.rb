require 'openssl'
require 'faker'
require 'tor'
TorControl = Tor

require_relative 'tor_requests/lib/tor_requests.rb'
require_relative 'tor-client.rb'
require_relative 'veed.rb'

tor = TorClient.connect(:port => 9051)
Veed.use_tor(tor)
# puts "Your computers own external address is #{tor.address} (should not be visible to Veed)"
votes = 0
true_votes = 0
stop = false
start = Time.now
# min_threads = 1
# max_threads = 5 # Amount of times to vote per ip
Thread.new {
  while(true)
    case gets.chomp
    when "exit","stop"
      exit if stop
      stop = true
      puts "Stopping after current vote. Type exit or stop again to shutdown immediately"
    # when /min (\d+)/
    #   min_threads = $1
    # when /max (\d+)/
    #   max_threads = $1
    else
      puts "I don't know what you mean by that"
    end
  end
}
# vote_threads = Array.new
count = 1
while(true)
  begin
    tor.new_session
    # count = rand(min_threads..max_threads)
    puts "Voting #{count} times with IP address #{tor.public_address}"
    # while vote_threads.length < count
    #   vote_threads.push Thread.new {
        time = Time.now
        true_votes += Veed.vote/2.0
        votes += 1
        puts "That took #{Time.now - time} seconds! Total votes: #{true_votes}/#{votes}"
    #   }
    # end
    # while vote_threads.length > 0
    #   vote_threads.shift.join
    # end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end
  break if stop
end

puts "Total votes: #{true_votes}/#{votes} in #{Time.at(Time.now - start).strftime("%T")}"
