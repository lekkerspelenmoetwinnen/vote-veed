require 'openssl'
require 'faker'
require 'timeout'

require_relative 'tor/lib/tor.rb'
TorControl = Tor
require_relative 'tor_requests/lib/tor_requests.rb'
require_relative 'tor-client.rb'
require_relative 'veed.rb'

tor = TorClient.connect(:port => 9051)
Veed.tor = tor
# puts "Your computers own external address is #{tor.address} (should not be visible to Veed)"
votes = 0
true_votes = 0
stop = false
show_addresses = false

# The lower the safety_level, the higher the chance Veed will recognize our votes as fake
# But the higher the safety level, the longer it takes to vote
# Currently possible values:
# => 1: Will only vote in the most important categories, using the minimum amount of web requests
# => 2: Will vote in all categories (but almost always at least the most important),
# =>    using much decreased amount of web requests
# => 3: Will vote in all categories (but almost always at least the most important),
# =>    using the same amount of webrequest a real voter would use (except for images, scripts and other page content)
Veed.safety_level = 3
timeout = 40 + Veed.safety_level*10

# Save the response body of requests. Only works if safety_level == 3
Veed.debug_save = true

Veed.open

input_thr = Thread.new {
  while(true)
    case gets.chomp
    when "exit","stop"
      Thread.main.exit if stop
      stop = true
      puts "Stopping after current vote. Type exit or stop again to shutdown immediately"
    when "ip","address","addresses"
      show_addresses = !show_addresses
    when /timeout (\d+)/
      timeout = $1.to_i
    when /safety (\d+)/
      Veed.safety_level = $1.to_i
    else
      puts "I don't know what you mean by that"
    end
  end
}

vote_threads = Hash.new
ports = Hash[(9052..9060).map { |num| [num, "£#{num}"] }]
ports[9050] = false
puts "Voting with #{ports.size} threads at the same time"
mutex = Mutex.new
start = Time.now

while(true)
  time = Time.now
  tor.new_session

  ports.each do |port,val|
    thr = vote_threads[port]
    if thr.nil? || thr.status == false || thr.status == nil
      vote_threads[port] = Thread.new {
        first = true
        begin
          http = Tor::HTTP.new('127.0.0.1',port)
          while true
            puts tor.public_address(http) if show_addresses || first
            first = false
            begin
              vote = 0
              Timeout.timeout(timeout) {
                vote = Veed.vote(http)/2.0
              }
              mutex.synchronize {
                true_votes += vote
                votes += 1
              }
            rescue Timeout::Error
              puts "#{port} timed out!"
            end
            ports[port] = true
            Thread.stop
          end
        rescue Exception => e
          puts e.message
          #puts e.backtrace.inspect
          raise e
        end
      }
    elsif thr.status == "sleep"
      thr.run
    end
  end
  sleep(1)
  vote_threads.each do |port,thr|
    sleep(0.1) until !thr.alive? || ports[port]
    ports[port] = false
  end

  puts "That took #{Time.now - time} seconds! Total votes: #{true_votes}/#{votes}"

  break if stop
end

elapsed = Time.now - start
puts "Total votes: #{true_votes}/#{votes} in #{(elapsed/3600).to_i}:#{((elapsed%3600)/60).to_i}:#{((elapsed%3600)%60).to_i}"
input_thr.exit
tor.quit
