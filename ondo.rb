require 'json'
require 'net/http'
require 'sinatra'
require 'sinatra/json'

get '/' do
    uri = URI('https://api.weather.gov/gridpoints/BTV/89,55')
    res = Net::HTTP.get(uri)
    data = JSON.parse(res)
    props = data["properties"]
    temp = props["temperature"]
    temps = temp["values"]
    times = temps.map do |values|
        parsedTime = values["validTime"].gsub('+00:00','Z')[0..19].split(/\D/)
        { time: Time.new(*parsedTime), temp: values["value"]}
    end
    ondo = times.min_by{|pair| (Time.now - pair[:time]).abs}[:temp]
    
    json :ondo => ondo
end

get '/*' do
  redirect '/'
end

__END__
