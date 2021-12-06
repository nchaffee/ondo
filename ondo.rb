require 'json'
require 'net/http'
require 'sinatra'
require 'sinatra/json'
require 'tzinfo'

get '/' do
    timezone = TZInfo::Timezone.get('US/Eastern')

    uri = URI('https://api.weather.gov/gridpoints/BTV/89,55')
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    ondo = data["properties"]["temperature"]["values"].map do |values|
        parsedTime = values["validTime"].gsub('+00:00','Z')[0..19].split(/\D/)
        { time: Time.new(*parsedTime, timezone.utc_offset), temp: values["value"]}
    end.min_by{|pair| (Time.now - pair[:time]).abs}[:temp]
    
    json :ondo => ondo
end

get '/*' do
  redirect '/'
end

__END__
