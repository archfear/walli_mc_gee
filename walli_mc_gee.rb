require 'erb'
require 'rubygems'
require 'sinatra'

get '/' do
  @wallimcgee =WalliMcGee.new
  <<-HTML
<html>
  <head>
    <title>WalliMcGee</title>
  </head>
  <body>
    <h1>#{@wallimcgee.speak}</h1>
  </body>
</html>
  HTML
end

class PeepList
  
  def initialize(peep_hash)
    @peeps = []
    @weights = []
    @total_weight = peep_hash.values.sum
    sorted_peeps = peep_hash.sort {|a,b| b[1]<=>a[1]}
    
    sorted_peeps.each do |peep, weight|
      @peeps << peep
      @weights << weight
    end
  end
  
  def random_peeps(peep_count, excluded_peeps = [])
    rpeeps = []
    excluded_peeps = excluded_peeps.to_a
    
    peep_count.times do
      peep = nil
      begin
        peep = self.random_peep
      end while(rpeeps.include?(peep) || excluded_peeps.include?(peep))
      
      rpeeps << peep
    end
    
    rpeeps
  end
  
  def random_peep
    @peeps[weighted_random_index]
  end
  
  def weighted_random_index
    @peeps.size.times do |x|
      return x if rand(@total_weight) < @weights[0..x].sum
    end
    return 0
  end
  
end

class Array
  def to_sentence
    case size
      when 0 then ""
      when 1 then self[0].to_s
      when 2
        "#{self[0]} and #{self[1]}"
      else
        "#{self[0...-1].join(', ')}, and #{self[-1]}"
    end
  end
  
  def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
  end
end

# An Ali/Willo simulation bot for Twitter
class WalliMcGee
  # twitter name => frequency of hangouts
  Peeps = PeepList.new(
    'aprilini' => 0.1,
    'aubs' => 0.7,
    'ceedub' => 0.1,
    'dan' => 0.1,
    'ian' => 0.1,
    'kimlaama' => 0.3,
    'quepol' => 0.1,
    'rk' => 0.3,
    'sharon' => 0.2,
    'spangley' => 1.0,
    'stephdub' => 0.3,
    'willotoons' => 1.0
  )
  
  Phrases = [
    'Hanging with <%=peeps%> at <%=location%>... Love my peeps!',
    'So good to be sharing drinks with <%=peeps%> at <%=location%>. I love you guys.',
    'Loving hanging out at <%=location%> with <%=peeps%>!',
    'Can\'t wait to go chill with <%=peeps%> at <%=location%>. Hearts to my chubies!',
    'Beers with <%=peeps%> at <%=location%>. W00t!',
    'At <%=location%> with <%=peeps%>. Holla!'
  ]
  
  Locations = [
    'Doc\'s Clock',
    '12 Galaxies',
    'Bottom of the Hill',
    '500 Club',
    'Zeitgeist',
    'The Hemlock'
  ]
  
  def speak(speaking_as=nil)
    speaking_as ||= %w(willotoons spangley)[rand(2)]
    ERB.new("#{speaking_as}: #{phrase}").result(binding)
  end
    
  def location; Locations[rand(Locations.size)] end
  
  def peeps
    how_many = rand(5) + 1
    peeps = Peeps.random_peeps(how_many, @speaking_as)
    peeps.map { |name| "@#{name}" }.to_sentence
  end
  
  def phrase; Phrases[rand(Phrases.size)] end
  
end
