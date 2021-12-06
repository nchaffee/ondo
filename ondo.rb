require 'json'
require 'net/http'
require 'sinatra'
require 'sinatra/json'
require 'tzinfo'

get '/' do
    timezone = TZInfo::Timezone.get('US/Eastern')
    now = Time.now.getlocal(timezone.utc_offset)
    uri = URI('https://api.weather.gov/gridpoints/BTV/89,55')
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    ondo = data["properties"]["temperature"]["values"].map do |values|
        parsedTime = values["validTime"].gsub('+00:00','Z')[0..19].split(/\D/)
        { time: Time.new(*parsedTime), temp: values["value"]}
    end.min_by{|pair| (now - pair[:time]).abs}[:temp]
    
    json :ondo => ondo
end

get '/*' do
  redirect '/'
end

__END__
