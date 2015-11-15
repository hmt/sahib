require 'sinatra'
require 'slim'
require 'sass'
require 'json'
require 'schild'
include SchildErweitert
require "#{File.dirname(__FILE__)}/lib/presenters"
include Presenters
require "#{File.dirname(__FILE__)}/lib/dokumente"

configure do
  puts "Sahib unter schild v#{Schild::VERSION}"
  set :dokumente, DokumentenSammlung.new
  set :views, ['views', 'dokumente', 'dokumente/partials']
  Slim::Engine.set_options pretty: true
end

configure :testing do
  set :raise_errors, true
  set :show_exceptions, false
end

helpers do
  def partial(template, locals = {})
    slim template, :layout => false, :locals => locals
  end

  def find_template(views, name, engine, &block)
    views.each { |v| super(v, name, engine, &block) }
  end

  def user_pass
    user = Nutzer.where(:US_LoginName => request.env["REMOTE_USER"]).first
    {:u => user.login,
     :p => user.crypt(user.password)}
  end
end

use Rack::Auth::Basic, "Zur Anmeldung bitte Schildbenutzer verwenden" do |username, password|
  nutzer = Nutzer.where(:US_LoginName => username).first
  nutzer && nutzer.password?(password)
end

error do
  'Fehler'
end

# sass style sheet generation
get '/css/:file.css' do
  scss params[:file].intern
end

get '/' do
  slim :home
end

get '/*.pdf' do
  file = Tempfile.new(['id_',  '.pdf'])
  # Damit slimer.js funktioniert, muss SLIMER_SSL_PROFILE (bei selbstsignierten Zertifikaten) und
  # SLIMERJSLAUNCHER gesetzt werden. Ersteres auf ein Profil, das hier beschrieben wird: http://darrendev.blogspot.de/2013/10/slimerjs-getting-it-to-work-with-self.html
  # und letzteres auf die ausführbare firefox binary (meist /usr/bin/firefox).
  if File.exist?(ENV["SLIMER_SSL_PROFILE"])
    profil = "-profile #{ENV['SLIMER_SSL_PROFILE']}"
  end
  puts cmd = `xvfb-run -a -e /dev/stdout slimerjs --debug=error #{profil} lib/pdf.js #{request.url.partition(".pdf")[0]} #{file.path} #{params[:pdf_format]} #{params[:pdf_orientierung]} #{user_pass[:u]} #{user_pass[:p] || ""}`

  send_file file.path, :type => :pdf
end

get '/suche/schueler/autocomplete.json' do
  content_type :json
  schueler = Schueler.where("Name LIKE :name OR Vorname LIKE :name", :name => "#{params[:pattern]}%").limit(30)
  if schueler.empty?
    halt 404
  else
    schueler = schueler.map{ |s| { :value => "#{s.name}, #{s.vorname} (#{s.klasse})", :status => s.status, :jahr => s.akt_schuljahr, :link => "/schueler/#{s.id}"} }.to_json
  end
end

get '/suche/klassen/autocomplete.json' do
  content_type :json
  klassen = Schueler.where(Sequel.ilike(:Klasse, "#{params[:pattern]}%")).all
  klassen = klassen.group_by{ |k| k.klasse }
  if klassen.empty?
    halt 404
  else
    ret = klassen.map do |klasse,schueler|
      if klasse.downcase == params[:pattern].downcase || klassen.count == 1
        jahrgaenge = schueler.group_by{ |s| s.akt_schuljahr }
        jahrgaenge.map{ |jahrgang,schueler_| {:value => "#{klasse} (#{schueler_.count{|s| s.status == 2}}), #{jahrgang}", :link => "/klasse/#{klasse}/#{jahrgang}"} }.reverse
      else
        {:value => "#{klasse} (#{schueler.count{|s| s.status == 2}})", :link => "/klasse/#{klasse}/#{schueler.max_by{ |s| s.akt_schuljahr }.akt_schuljahr}"}
      end
    end
    ret.flatten.to_json
  end
end

get '/schueler/:id/?:jahr?/?:abschnitt?' do
  schueler = SchuelerPresenter.new(Schueler[params[:id].to_i])
  jahr = params[:jahr] ? params[:jahr].to_i : schueler.akt_schuljahr
  abschnitt = params[:abschnitt] ? params[:abschnitt].to_i : schueler.akt_abschnitt
  slim :schueler, :locals => { :s => schueler,
                               :jahr => jahr,
                               :abschnitt => abschnitt,
                               :dokumente => settings.dokumente.select{|d| d.verfuegbar(schueler.asd_schulform[0])},
                               :title => "#{schueler.vorname} #{schueler.name}, #{schueler.klasse}" }
end

get '/klasse/:name/:jahrgang' do
  schueler = Schueler.where(:Klasse => params[:name], :AktSchuljahr => params[:jahrgang].to_i)
  halt 404, "Keine Schüler gefunden" if schueler.count == 0
  klasse = KlassenPresenter.new(schueler)
  slim :klasse, :locals => {:klasse => klasse,
                            :dokumente => settings.dokumente.select{|d| d.verfuegbar(schueler.first.asd_schulform[0])},
                            :title => "#{params[:name]}, #{params[:jahrgang]}"}
end

get '/klasse/:name/:jahr/:abschnitt' do
  abschnitte = Abschnitt.where(:Klasse => params[:name], :Jahr => params[:jahr], :Abschnitt => params[:abschnitt])
  schueler = Schueler.where(:ID => abschnitte.map{|s| s.Schueler_ID})
  halt 404, "Keine Schüler gefunden" if schueler.count == 0
  klasse = KlassenPresenter.new(schueler)
  slim :klasse_abschnitt, :locals => {:klasse => klasse,
                                      :jahr => params[:jahr].to_i,
                                      :abschnitt => params[:abschnitt].to_i,
                                      :dokumente => settings.dokumente.select{|d| d.verfuegbar(schueler.first.asd_schulform[0])},
                                      :title => "#{params[:name]}, #{params[:abschnitt]}. Halbjahr #{params[:jahr]}"}
end

get '/dokumente/:doc/:jahr/:abschnitt/:id/?*' do
  schueler = Schueler.where(:ID => Array(params[:id].split(","))) #kein [], weil hier mit Dataset gearbeitet wird!
  halt 404, "Keine Schüler gefunden" if schueler.count == 0
  klasse = KlassenPresenter.new(schueler)
  doc = settings.dokumente.find{|d|d.name == params[:doc]}
  slim doc.name.to_sym, :locals => { :schueler => klasse,
                                     :jahr => params[:jahr].to_i,
                                     :abschnitt => params[:abschnitt].to_i,
                                     :doc => doc,
                                     :pdf_name => "#{params[:jahr].to_i}_#{params[:abschnitt].to_i}_#{(klasse.count == 1) ? klasse.first.klasse+'_'+schueler.first.name : klasse.first.klasse.upcase}_#{doc.name}",
                                     :pdf_format => doc.get("Format"),
                                     :pdf_orientierung => doc.get("Orientierung"),
                                     :title => "Dokumentenansicht" }
end

get '/images/schueler/:id.jpg' do
  file = Tempfile.new(['id_',  '.jpg'])
  foto = Schueler[params[:id].to_i].foto
  unless foto.nil?
    File.open(file, 'w'){|f| f.write foto}
    send_file file.path, :type => :jpg, :disposition => :inline
  else
    halt 404
  end
end
