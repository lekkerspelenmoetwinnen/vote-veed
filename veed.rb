module Veed
  def self.use_tor(tor)
    @@tor = tor
  end

  def self.vote
    headers = generate_headers
    login(headers)
    cats = categories
    cats.length.times {
      if vote_category(headers,cats,cats.length == 1 || ((cats["11"].nil? || cats["13"].nil? || rand(10) == 0) && rand(2) == 0))
        break;
      end
    }
    res = 0
    res += 1 if cats["11"].nil?
    res += 1 if cats["13"].nil?
    puts "Voted on #{categories.length - cats.length} categories! (#{res})"
    res
  end

  def self.login(headers)
    headers.merge!("Cookie" => @@tor.get(URI("https://stem.veed.nl/"),headers)['set-cookie'].split('; ')[0])
    name = rand(2) == 0 ? (rand(2) == 0 ? Faker::Name.name : Faker::Name.first_name) : random_string(6,14)
    body = "action=voter&name=#{name}&email=#{Faker::Internet.free_email(rand(2) == 0 ? name : nil)}&phone=&birthdate=#{rand(2) == 0 ? random_date : ""}"
    post(URI("https://stem.veed.nl/"),body,headers.merge("Content-Type" => "application/x-www-form-urlencoded", "content-length" => body.bytesize))
  end

  def self.vote_category(headers,cats,last)
    category = cats.keys.sample
    @@tor.get(URI("https://stem.veed.nl/kies-categorie"),headers).value
    body = "action=vote-categories&veed_category_id=#{category}"
    post(URI("https://stem.veed.nl/kies-categorie"),body,headers.merge("Content-Type" => "application/x-www-form-urlencoded", "content-length" => body.bytesize))
    @@tor.get(URI("https://stem.veed.nl/kies-genomineerde"),headers).value
    genomineerde = cats.delete(category)
    body = "action=vote-nominees&veed_nominee_id=#{genomineerde.is_a?(Array) ? genomineerde.sample : genomineerde}"
    post(URI("https://stem.veed.nl/kies-genomineerde"),body,headers.merge("Content-Type" => "application/x-www-form-urlencoded", "content-length" => body.bytesize))
    @@tor.get(URI("https://stem.veed.nl/stemmen-gelukt"),headers).value
    if !last then
      body = "action=vote-success"
      post(URI("https://stem.veed.nl/stemmen-gelukt"),body,headers.merge("Content-Type" => "application/x-www-form-urlencoded", "content-length" => body.bytesize))
    else
      @@tor.get(URI("https://stem.veed.nl/bedankt-voor-je-stem"),headers).value
    end
    return last
  end

  def self.post(*args)
    res = @@tor.post(*args)
    res.value if !res.code == "302"
  end

  # Attempt to generate believable headers
  def self.generate_headers
    {
      "accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "accept-encoding" => "gzip, deflate, br",
      "accept-language" => "nl,en-US;q=0.7,en;q=0.3",
      "user-agent" => Faker::Internet.user_agent #"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:63.0) Gecko/20100101 Firefox/63.0" #Firefox 63 win 10. Add other browsers later
    }
  end

  POSSIBLE_CHARS = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
  def self.random_string(minlength,maxlength)
    (0...(minlength+rand(maxlength-minlength))).map{POSSIBLE_CHARS[rand(POSSIBLE_CHARS.length)]}.join
  end

  def self.random_date
    rand(Date.civil(1985,1,1)..Date.civil(2005,12,31)).strftime("%e-%-m-%Y")
  end

  def self.categories
    {
      "1" => "2154", # Beste mannelijke Youtuber
      "2" => ["46","11","44","139","5378"], # Beste vrouwelijke Youtuber
      "3" => ["137","2264","216","5378","38"], # Beste muziek Youtuber
      "4" => "2154", # Beste Youtube Kanaal
      # "6" => # Beste Comedy Youtuber
      # "7" => # Beste vlogger
      "8" => ["258","119","121","163","4192"], # Beste Nieuwkomer
      "9" => "4994",# Beste Youtube Video
      # "10" => # Beste Youtube Serie
      "11" => "7483", # Beste Gaming Youtuber
      # "12" => # Beste Beauty Youtuber
      "13" => "7483", # Beste Twitcher
      # "14" => # Beste Instagrammer
    }
  end
end
