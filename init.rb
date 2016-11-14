require 'sinatra'
require 'slim'
require 'sass'

class SahibInit < Sinatra::Application
  configure do
    enable :logging
  end

  helpers do
    def restart
      puts "Server neu starten …"
      File.open("./tmp/restart.txt", "w"){}
    end
  end

  not_found do
    redirect '/init/datenbank'
  end

  get '/restart' do
    restart
  end

  get '/ping' do
    status 503
  end

  get '/init/datenbank' do
    slim :datenbank, :layout => false
  end

  post '/init/datenbank/test' do
    adapter, host, db, user, password = params.values
    begin
      @db=Sequel.connect("#{adapter}://#{host}/#{db}?user=#{user}&password=#{password}&zeroDateTimeBehavior=convertToNull")
    rescue
      "false"
    else
      if @db
        begin
          @db.test_connection
        rescue
          "false"
        else
          "true"
        end
      end
    end
  end

  post '/init/datenbank/speichern' do
    Config.save(params) ? "true" : "false"
  end
end

