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
yaml = YAML.load_file('./config/strings.yml')
Slim::Engine.set_default_options pretty: true

helpers do
  def partial(template, locals = {})
    slim template, :layout => false, :locals => locals
  end

  def flash
    @flash = session.delete(:flash)
  end
end

class SchuelerPresenter
  def initialize(s)
    @s = s
  end

  def klasse
    @s.first.Klasse
  end

  def anzahl
    @s.count
  end

  def schueler_details
    @s.map{ |s| {:name => s.Name, :vorname => s.Vorname, :adresse => "#{s.Strasse}, #{s.PLZ} #{s.OrtAbk}", :telefon => s.Telefon}}
  end
end

class AbschnittePresenter
  def initialize(s)
    @abschnitte = s.abschnitte
  end

  def jahr_und_abschnitt
    @abschnitte.map{ |a| {:jahr => a.Jahr, :abschnitt => a.Abschnitt, :schuljahr => a.schuljahr} }
  end

  def noten
    liste = {}
    @abschnitte.each_with_index do |a,i|
      a.noten.each do |n|
        liste[n.fach.FachKrz.to_sym] ||= []
        liste[n.fach.FachKrz.to_sym][i] = (n.NotenKrz ||= "")
      end
    end
    return liste
  end

  def fehlstunden
    @abschnitte.map{ |a| a.SumFehlStd }
  end

  def fehlstunden_ue
    @abschnitte.map{ |a| a.SumFehlStdU }
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
  schueler = schueler.map{ |s| { :value => "#{s.Name}, #{s.Vorname} (#{s.Klasse})", :link => "/schueler/#{s.ID}"} }.to_json
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
  slim :student, :locals => { :s => schueler, :title => "#{schueler.Vorname} #{schueler.Name}, #{schueler.Klasse}" }
end

get '/klasse/:name' do
  halt 404, "noch nicht fertig"
  schueler = Schueler.where(:Klasse => params[:name]).all
  slim :klassen, :locals => {:schueler => schueler, :title => "Übersicht #{params[:name]}"}
end

get '/klasse/:name/:jahrgang' do
  halt 404, "noch nicht fertig"
  schueler = Schueler.where(:Klasse => params[:name], :AktSchuljahr => params[:jahrgang])
  slim :klasse, :locals => {:schueler => schueler, :title => params[:name]}
end

get '/:doc/:id/:jahr/:abschnitt' do
  schueler = Schueler.where(:ID => params[:id]).first
  slim params[:doc].to_sym, :layout => false,  :locals => { :yaml => yaml, :s => schueler, :hj => schueler.halbjahr(params[:jahr], params[:abschnitt]), :title => "#{schueler.Vorname} #{schueler.Name}, #{schueler.Klasse}" }
end

