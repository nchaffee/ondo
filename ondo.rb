require 'json'
require 'net/http'
require 'sinatra'
require 'sinatra/json'
require 'tzinfo'

get '/' do
    offset = TZInfo::Timezone.get('US/Eastern').utc_offset
    now = Time.now.getlocal(offset)

    uri = URI('https://api.weather.gov/gridpoints/BTV/89,55')
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    ondo = data["properties"]["temperature"]["values"].map do |values|
        parsed_time = values["validTime"].gsub('+00:00','Z')[0..19].split(/\D/)
        new_time = Time.new(*parsed_time, offset)
        { time: new_time, temp: values["value"]}
    end.min_by{|pair| (now - pair[:time]).abs}[:temp]

    json :ondo => ondo
end

get '/*' do
  redirect '/'
end

__END__