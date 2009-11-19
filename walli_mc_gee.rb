# An Ali/Willo simulation bot for Twitter

require 'rubygems'
require 'sinatra'

class Array
  def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
  end
  
  def to_sentence
    case size
      when 0 then ""
      when 1 then self[0].to_s
      when 2 then "#{self[0]} and #{self[1]}"
      else "#{self[0...-1].join(', ')}, and #{self[-1]}"
    end
  end
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
      return x  if rand(@total_weight) < @weights[0..x].sum
    end
    return 0
  end
end

configure do
  # twitter name => frequency of hangouts
  PEEP_LIST = PeepList.new(
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

  PHRASES = [
    'Hanging with <%=peeps(@speaking_as)%> at <%=location%>... Love my peeps!',
    'So good to be sharing drinks with <%=peeps(@speaking_as)%> at <%=location%>. I love you guys.',
    'Loving hanging out at <%=location%> with <%=peeps(@speaking_as)%>!',
    'Can\'t wait to go chill with <%=peeps(@speaking_as)%> at <%=location%>. Hearts to my chubies!',
    'Beers with <%=peeps(@speaking_as)%> at <%=location%>. W00t!',
    'At <%=location%> with <%=peeps(@speaking_as)%>. Holla!'
  ]

  LOCATIONS = [
    'Doc\'s Clock',
    '12 Galaxies',
    'Bottom of the Hill',
    '500 Club',
    'Zeitgeist',
    'The Hemlock'
  ]
end

helpers do
  def speaker; %w(willotoons spangley)[rand(2)] end
  
  def location; LOCATIONS[rand(LOCATIONS.size)] end

  def peeps(speaking_as)
    how_many = rand(4) + 1
    peep_list = PEEP_LIST.random_peeps(how_many, speaking_as)
    peep_list.collect! { |name| "@#{name}" }
    peep_list.to_sentence
  end

  def phrase; PHRASES[rand(PHRASES.size)] end
end

get '/' do
  @speaking_as = speaker
  
  erb <<-ERB
<html>
  <head>
    <title>WalliMcGee</title>
  </head>
  <body>
    <h1>@<%= @speaking_as %>: #{phrase}</h1>
  </body>
</html>
  ERB
end
