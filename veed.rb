module Veed
  class << self
    attr_accessor :safety_level, :tor, :debug_save, :files
  end

  def self.open
    self.files = Hash.new
    ["index","kies-categorie","kies-genomineerde","stemmen-gelukt","bedankt-voor-je-stem"].each do |fname|
      require_relative("webpages/#{fname}.html.rb") if File.exist?("webpages/#{fname}.html.rb")
      require_relative("webpages/#{fname}.php.rb") if File.exist?("webpages/#{fname}.php.rb")
    end
  end

  def self.add_file(name,str)
    self.files[name] = /\A#{str.empty? ? "\\Z" : Regexp.quote(str).gsub!("REGEXPHERE",".*")}/m
  end

  def self.vote(http)
    headers = generate_headers
    login(http,headers)
    cats = categories
    cats.length.times {
      if vote_category(http,headers,cats,cats.length == 1 || (safety_level > 1 && (cats["11"].nil? || cats["13"].nil? || rand(10) == 0) && rand(2) == 0))
        break;
      end
    }
    res = 0
    res += 1 if cats["11"].nil?
    res += 1 if cats["13"].nil?
    puts "Voted on #{categories.length - cats.length} categories! (#{res})"
    res
  end

  def self.login(http,headers)
    headers.merge!("Cookie" => get("index",http,URI("https://stem.veed.nl/"),headers)['set-cookie'].split('; ')[0])
    name = rand(2) == 0 ? (rand(2) == 0 ? Faker::Name.name : Faker::Name.first_name) : random_string(6,14)
    bdate = random_date
    form_data = {"action" => "voter", "name" => name, "email" => Faker::Internet.free_email(rand(2) == 0 ? name : nil), "phone" => "", "birthdate" => rand(2) == 0 ? bdate.strftime("%e-%-m-%Y") : "", "terms_agreed" => "1"}
    form_data["parent_permission"] = "1" if bdate > Date.civil(2002,12,31)
    post("index",http,URI("https://stem.veed.nl/"),form_data,headers)
  end

  def self.vote_category(http,headers,cats,last)
    category = cats.keys.sample
    get("kies-categorie",http,URI("https://stem.veed.nl/kies-categorie"),headers) if safety_level > 2
    post("kies-categorie",http,URI("https://stem.veed.nl/kies-categorie"),{"action" => "vote-categories", "veed_category_id" => category},headers)
    get("kies-genomineerde",http,URI("https://stem.veed.nl/kies-genomineerde"),headers) if safety_level > 2
    genomineerde = cats.delete(category)
    post("kies-genomineerde",http,URI("https://stem.veed.nl/kies-genomineerde"),{"action" => "vote-nominees", "veed_nominee_id" => genomineerde.is_a?(Array) ? genomineerde.sample : genomineerde},headers)
    get("stemmen-gelukt",http,URI("https://stem.veed.nl/stemmen-gelukt"),headers) if safety_level > 2
    if !last then
      post("stemmen-gelukt",http,URI("https://stem.veed.nl/stemmen-gelukt"),{"action" => "vote-success"},headers)
    else
      get("bedankt-voor-je-stem",http,URI("https://stem.veed.nl/bedankt-voor-je-stem"),headers) if safety_level > 1
    end
    return last
  end

  def self.post(file,*args)
    res = tor.post(*args)
    res.value if !res.code == "302"
    # File.open("webpages/#{file}.php","w") {|f| f.write(res.body)} if debug_save && !res.nil? && !File.exist?("webpages/#{file}.php")
    if !files["#{file}.php"].match(res.body)
      rs = random_string(10,10)
      File.open("webpages/different/#{file}#{rs}.php","w") {|f| f.write(res.body)}
      # File.delete("webpages/different/#{file}#{rs}.php") if FileUtils.compare_file("webpages/different/#{file}#{rs}.php","webpages/#{file}.php")
    end
    res
  end

  def self.get(file,*args)
    res = tor.get(*args)
    res.value
    # File.open("webpages/#{file}.html","w") {|f| f.write(res.body)} if debug_save && !res.nil? && !File.exist?("webpages/#{file}.html")
    if file != "kies-genomineerde" && !files["#{file}.html"].match(res.body)
      rs = random_string(10,10)
      File.open("webpages/different/#{file}#{rs}.html","w") {|f| f.write(res.body); f.write(files["#{file}.html"].to_s)}
      # File.delete("webpages/different/#{file}#{rs}.html") if FileUtils.compare_file("webpages/different/#{file}#{rs}.html","webpages/#{file}.html")
    end
    res
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
    rand(Date.civil(1994,1,1)..Date.civil(2007,12,31))
  end

  def self.categories
    if safety_level > 1 then
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
    else
      {
        "11" => "7483", # Beste Gaming Youtuber
        "13" => "7483", # Beste Twitcher
      }
    end
  end
end
