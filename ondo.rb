require 'sinatra'
require 'haml'
require 'net/http'
require 'json'

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
    @ondo = times.min_by{|pair| (Time.now - pair[:time]).abs}[:temp]
    
    haml :index
end

get '/*' do
  redirect '/'
end

__END__
@@ layout
%html
  %head
    %title 現在温度
  %body
    %div(align='center')
      =yield

@@ index
%p(style="font-size:6em;font-weight:bold#{@ondo > 0 ? ';color:red' : ''}")
  温度
  = sprintf('%.2f', @ondo)

%p(style="font-size:6em;font-weight:bold#{@ondo > 0 ? ';color:red' : ''}")
  カ氏温度
  = sprintf('%.0f', @ondo * 9 / 5 + 32)