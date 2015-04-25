require 'sinatra'
require 'slim'
require 'sass'
require 'json'
require 'envyable'
# environment verwenden
Envyable.load('./config/env.yml', 'testing')
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

class AbschnittePresenter < Schild::Abschnitt
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

get '/app/search' do
  if params[:search_id]
    redirect "/student/#{params[:search_id]}"
  else
    redirect '/'
  end
end

get '/search/autocomplete.json' do
  content_type :json
  schueler = Schueler.where(Sequel.ilike(:Name, "#{params[:pattern]}%")).or(Sequel.ilike(:Klasse, "#{params[:pattern]}%")).limit(30)
  schueler.map{ |s| {:id => s.ID, :name => s.Name, :vorname => s.Vorname, :klasse => s.Klasse, :value => "#{s.Name}, #{s.Vorname}, #{s.Klasse}"} }.to_json
end

get '/student/:id' do
  schueler = Schueler[params[:id]]
  slim :student, :locals => { :s => schueler, :title => "#{schueler.Vorname} #{schueler.Name}, #{schueler.Klasse}" }
end

get '/:doc/:id/:jahr/:abschnitt' do
  schueler = Schueler.where(:ID => params[:id]).first
  slim params[:doc].to_sym, :layout => false,  :locals => { :yaml => yaml, :s => schueler, :hj => schueler.halbjahr(params[:jahr], params[:abschnitt]), :title => "#{schueler.Vorname} #{schueler.Name}, #{schueler.Klasse}" }
end

