require "sequel"
require "sinatra"
require "sinatra/extension"
require 'slim'
require 'sass'
require "#{File.dirname(__FILE__)}/lib/helpers"
require "#{File.dirname(__FILE__)}/lib/repo"

def db_test
  ENV['S_ADAPTER'] = "jdbc:mysql" if RUBY_ENGINE == 'jruby'
  begin
    @db = Sequel.connect("#{ENV['S_ADAPTER']}://#{ENV['S_HOST']}/#{ENV['S_DB']}?user=#{ENV['S_USER']}&password=#{ENV['S_PASSWORD']}&zeroDateTimeBehavior=convertToNull")
    @db.test_connection
  rescue Exception => e
    puts e
    return false
  end
end

if db_test
  puts "Konfiguration für Datenbank unter »#{ENV['S_HOST']}/#{ENV['S_DB']}« gefunden"
  puts "Sahib starten …"
  require "#{File.dirname(__FILE__)}/sahib"
  require 'rack/cache'

  use Rack::Cache,
    metastore:    'file:./tmp/rack/meta',
    entitystore:  'file:./tmp/rack/body',
    verbose:      false

  run Sahib.run_sahib
else
  puts "Keine Verbindungsdaten gefunden, Sahib-Konfiguration starten"
  require "#{File.dirname(__FILE__)}/init"
  run SahibInit
end
