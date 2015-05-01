require 'sinatra'
require 'slim'
require 'sass'
require 'json'
require 'envyable'
# environment verwenden
#Envyable.load('./config/env.yml', 'testing')
Envyable.load('./config/env.yml', 'development')
require 'schild'
include Schild
require "#{File.dirname(__FILE__)}/presenters"
include Presenters
yaml = YAML.load_file('./config/strings.yml')

configure do
  Slim::Engine.set_options pretty: true
  PDFKit.configure do |config|
    config.wkhtmltopdf = '/usr/bin/wkhtmltopdf'
    config.default_options = {
      :margin_bottom => '0mm',
      :margin_top => '0mm',
      :margin_left => '0mm',
      :margin_right => '0mm',
      :page_size => 'A4',
      :orientation => 'Portrait',
      :print_media_type => true
    }
  end
end

helpers do
  def partial(template, locals = {})
    slim template, :layout => false, :locals => locals
  end

  def flash
    @flash = session.delete(:flash)
  end
end

not_found do
  'Seite nicht gefunden'
end

error do
  'Fehler'
end

# sass style sheet generation
get '/css/:file.css' do
  halt 404 unless File.exist?("views/#{params[:file]}.scss")
  time = File.stat("views/#{params[:file]}.scss").ctime
  last_modified(time)
  scss params[:file].intern
end

get '/' do
  slim :home
end

get '/suche/schueler/autocomplete.json' do
  content_type :json
  schueler = Schueler.where(Sequel.ilike(:Name, "#{params[:pattern]}%")).limit(30)
  if schueler.empty?
    halt 404
  else
    schueler = schueler.map{ |s| { :value => "#{s.Name}, #{s.Vorname} (#{s.Klasse})", :link => "/schueler/#{s.ID}"} }.to_json
  end
end

get '/suche/klassen/autocomplete.json' do
  content_type :json
  klassen = Schueler.where(Sequel.ilike(:Klasse, "#{params[:pattern]}%")).all
  klassen = klassen.group_by{ |k| k.Klasse }
  if klassen.empty?
    404
  else
    ret = klassen.map do |klasse,schueler|
      if klasse.downcase == params[:pattern].downcase || klassen.count == 1
        jahrgaenge = schueler.group_by{ |s| s.AktSchuljahr }
        jahrgaenge.map{ |jahrgang,schueler_| {:value => "#{klasse} (#{schueler_.count}), #{jahrgang}", :link => "/klasse/#{klasse}/#{jahrgang}"} }
      else
        {:value => "#{klasse} (#{schueler.count})", :link => "/klasse/#{klasse}"}
      end
    end
    ret.flatten.to_json
  end
end

get '/schueler/:id' do
  schueler = Schueler[params[:id]]
  abschnitte = AbschnittePresenter.new(schueler)
  slim :schueler, :locals => { :s => schueler, :abschnitte => abschnitte, :title => "#{schueler.Vorname} #{schueler.Name}, #{schueler.Klasse}" }
end

get '/klasse/:name' do
  schueler = Schueler.where(:Klasse => params[:name])
  slim :klassen, :locals => {:s => schueler, :title => "Übersicht #{params[:name]}"}
end

get '/klasse/:name/:jahrgang' do
  schueler = Schueler.where(:Klasse => params[:name], :AktSchuljahr => params[:jahrgang])
  klasse = SchuelerPresenter.new(schueler)
  slim :klasse, :locals => {:k => klasse, :s => schueler, :title => params[:name]}
end

get '/:doc/:id/:jahr/:abschnitt' do
  schueler = Schueler.where(:ID => params[:id])
  if schueler.count == 0
    schueler = Schueler.where(:Status => 2, :Klasse => params[:id])
  end
  klasse = SchuelerPresenter.new(schueler)
  slim params[:doc].to_sym, :locals => { :yaml => yaml,
                                         :schueler => schueler.all,
                                         :jahr => params[:jahr],
                                         :abschnitt => params[:abschnitt],
                                         :k => klasse,
                                         :title => "#{klasse.klasse}" }
end

