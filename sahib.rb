require 'schild'
require 'pry' if development?
include SchildErweitert
require "#{File.dirname(__FILE__)}/lib/presenters"
include Presenters
require "#{File.dirname(__FILE__)}/lib/easter"

class Sahib < Sinatra::Application
  configure do
    puts "Sahib unter schild v#{Schild::VERSION}"
    use Rack::Auth::Basic, "Zur Anmeldung bitte Schildbenutzer verwenden" do |username, password|
      nutzer = Nutzer.where(:US_LoginName => username).first
      nutzer && nutzer.password?(password)
    end
    enable :sessions
    set :session_secret, (ENV['S_SESSION_SECRET'] || 'your_secret')
    puts "Setzen Sie `S_SESSION_SECRET` in Ihrer Konfigurationsdatei" unless ENV['S_SESSION_SECRET']
    set :views, ['views']
    set :public_folder, "public"
    Slim::Engine.set_options pretty: true
  end

  configure :testing do
    set :raise_errors, true
    set :show_exceptions, false
  end

  helpers Helpers

  get '/css/:file.css' do
    scss params[:file].intern
  end

  get '/' do
    slim ""
  end

  get '/*.pdf' do
    file = Tempfile.new(['id_',  '.pdf'])
    # Damit slimer.js funktioniert, muss SLIMER_SSL_PROFILE (bei selbstsignierten Zertifikaten) und
    # SLIMERJSLAUNCHER gesetzt werden. Ersteres auf ein Profil, das hier beschrieben wird: http://darrendev.blogspot.de/2013/10/slimerjs-getting-it-to-work-with-self.html
    # und letzteres auf die ausführbare firefox binary (meist /usr/bin/firefox).
    if File.exist?(ENV["SLIMER_SSL_PROFILE"] || "")
      profil = "-profile #{ENV['SLIMER_SSL_PROFILE']}"
    end
    slimer = "slimerjs --debug=true #{profil} lib/pdf.js #{request.url.partition(".pdf")[0]} #{file.path} #{params[:pdf_format]} #{params[:pdf_orientierung]} #{user_pass[:u]} #{user_pass[:p] || ""}"
    puts slimer
    begin
      puts `xvfb-run -a -e /dev/stdout #{slimer}`
    rescue
      puts cmd = `Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & DISPLAY=:0.0 #{slimer} && killall Xvfb`
    end
    send_file file.path, :type => :pdf
  end

  get '/suche/schueler/autocomplete.json' do
    content_type :json
    schueler = Schueler.where("Name LIKE :name OR Vorname LIKE :name",
                              :name => "#{params[:pattern]}%").limit(30)
    if schueler.empty?
      halt 404
    else
      schueler = schueler.map{ |s| { :value => "#{s.name}, #{s.vorname} (#{s.klasse})",
                                     :status => s.status, :jahr => s.akt_schuljahr,
                                     :link => "/auswahl/schueler/#{s.akt_schuljahr}/#{s.akt_abschnitt}/#{s.id}"} }.to_json
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
          jahrgaenge.map{ |jahrgang,schueler_| {:value => "#{klasse} (#{schueler_.count{|s| s.status == 2}}), #{jahrgang}",
                                                :link => "/auswahl/klasse/#{jahrgang}/#{schueler.map{|s|s.id}.join(",")}"} }.reverse
        else
          ss = schueler.max_by{ |s| s.akt_schuljahr }
          {:value => "#{klasse} (#{schueler.count{|s| s.status == 2}})",
           :link => "/auswahl/klasse/#{ss.akt_schuljahr}/#{ss.akt_abschnitt}/#{schueler.map{|s|s.id}.join(",")}"}
        end
      end
      ret.flatten.to_json
    end
  end

  get '/suche/:jahr/:abschnitt/:klasse' do
    klasse = Abschnitt.where(:Klasse => params[:klasse], :Jahr => params[:jahr], :Abschnitt => params[:abschnitt]).select(:Schueler_ID).all.map{|k|k.schueler_id}
    redirect "/auswahl/klasse/#{params[:jahr]}/#{params[:abschnitt]}/#{klasse.join(',')}"
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

  get '/warnungen/warnungen.json' do
    content_type :json
    Presenters::Warnung.flush.to_json
  end

  get '/ping' do
    status 200
  end

  get '/restart' do
    restart
  end

  get '/auswahl/:doc/?:jahr?/?:abschnitt?/:id/?*' do
    schueler_gruppe= Schueler.where(:ID => Array(params[:id].split(","))) #kein [], weil hier mit Dataset gearbeitet wird!
    klasse = Presenters::KlassenPresenter.new(schueler_gruppe)
    halt 404, "Keine Schüler gefunden" if klasse.empty?
    klassenbezeichnung = params[:klasse] || klasse.first.halbjahr(params[:jahr], params[:abschnitt]).klasse rescue klasse.first.klasse
    versetzung = Versetzung.first(:Klasse => klassenbezeichnung)
    slim params[:doc].to_sym, :locals => { :klasse => klasse,
                                           :dokumente => dokumente(settings.repos).select{|d| d.verfuegbar(klasse.s.asd_schulform[0])},
                                           :jahr => (params[:jahr] ? params[:jahr].to_i : klasse.s.akt_schuljahr),
                                           :abschnitt => (params[:abschnitt] ? params[:abschnitt].to_i : klasse.s.akt_abschnitt),
                                           :versetzung => versetzung}
  end
end

module SahibRepo
  extend Sinatra::Extension
  helpers Helpers

  get '/css/:file.css' do
    scss params[:file].intern
  end

  get '/:doc/:jahr/:abschnitt/:id/?*' do
    schueler = Schueler.where(:ID => Array(params[:id].split(","))) #kein [], weil hier mit Dataset gearbeitet wird!
    halt 404, "Keine Schüler gefunden" if schueler.count == 0
    doc = settings.repo.find{|d| d.document_key == params[:doc]}
    pass if doc.nil?
    slim params[:doc].to_sym, :layout => doc.get("Layout"), :locals => { :schueler => Presenters::KlassenPresenter.new(schueler),
                                                               :jahr => (params[:jahr] ? params[:jahr].to_i : schueler.first.akt_schuljahr),
                                                               :abschnitt => (params[:abschnitt] ? params[:abschnitt].to_i : schueler.first.akt_abschnitt),
                                                               :doc => doc,
                                                               :repo => settings.repo}
  end
end

class SahibRepoAdmin < Sinatra::Application
  get '/repos' do
    slim :repos
  end

  get '/repos/update/all' do
    settings.repos.all?{|r|r.update}.to_s
  end

  put '/repos/toggle-state' do
    content_type :json
    repo = settings.repos.find{|r|r.repo_name == params[:id]}
    settings.config['S_REPOS'][repo.location]['enabled'] = !repo.enabled?
    Config.update(settings.config) ? "true" : "false"
  end

  put '/repos/update' do
    content_type :json
    repo = settings.repos.find{|r|r.repo_name == params[:id]}
    repo.update ? "true" : "false"
  end

  delete '/repos/delete' do
    content_type :json
    repo = settings.repos.find{|r|r.repo_name == params[:id]}
    settings.config['S_REPOS'].delete(repo.location)
    if repo.is_a?(GitRepo) && Dir.exist?(repo.location+"/.git")
      `rm -rf "#{repo.location}"`
    end
    Config.update(settings.config) ? "true" : "false"
  end

  post '/repos/create' do
    case params[:klass]
    when "GitRepo"
      begin
        print "Klone #{params[:origin]} nach #{settings.config['S_REPO_LOCATION']+"/"+params[:name]} … "
        repo = Git.clone(params[:origin], settings.config['S_REPO_LOCATION']+"/"+params[:name])
        puts "✓"
        location = repo.dir.path
      rescue
        puts "✘ Klonen fehlgeschlagen"
        location = nil
      end
    when "LocalRepo"
      location = params[:origin]
    end
    if location
      (settings.config['S_REPOS'] ||= {})[location] = {
        'klass' => params[:klass],
        'origin' => params[:origin],
        'enabled' => true
      }
      Config.update(settings.config)
      "true"
    else
      "false"
    end
  end
end

