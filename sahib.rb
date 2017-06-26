require 'sequel'
require 'sinatra'
require 'sinatra/extension'
require 'slim'
require 'sass'
require 'rack/cache'
require 'json'
require 'daybreak'
require 'rest-client'
require 'nullobject'
require 'schild'
include SchildErweitert
require "#{File.dirname(__FILE__)}/lib/helpers"
require "#{File.dirname(__FILE__)}/lib/repo"
require "#{File.dirname(__FILE__)}/lib/presenters"
include Presenters
require "#{File.dirname(__FILE__)}/lib/easter"
# require 'pry' if development?

module Sahib
  class Sahib < Sinatra::Application
    configure do
      puts "Sahib unter schild v#{Schild::VERSION}"
      puts "Passwortabfrage wurde deaktiviert." if ENV['S_NO_PASSWORD'] == "true"
      unless ENV['S_NO_PASSWORD'] == "true"
        use Rack::Auth::Basic, "Zur Anmeldung bitte Schildbenutzer verwenden" do |username, password|
          nutzer = Nutzer.where(:US_LoginName => username).first
          nutzer && nutzer.password?(password)
        end
      end
      use Rack::Cache,
        metastore:    'file:./tmp/rack/meta',
        entitystore:  'file:./tmp/rack/body',
        verbose:      false
      enable :sessions
      set :session_secret, (ENV['S_SESSION_SECRET'] || 'your_secret')
      puts "Setzen Sie `S_SESSION_SECRET` in Ihrer Konfigurationsdatei" unless ENV['S_SESSION_SECRET']
      set :views, ['views']
      set :public_folder, "public"
      Slim::Engine.set_options pretty: true
    end

    configure :testing do
      set :raise_errors, true
      set :dump_errors, false
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
      # Setzt PDF Container voraus...
      halt 404, "Kein PDF-Renderer erreichbar" unless RestClient.get('pdf:3000/').code == 200
      file = Tempfile.new(['id_',  '.pdf'])
      format, orientierung = params[:pdf_format], params[:pdf_orientierung]
      begin
        doc_url = "http://#{user_pass}@sahib:9393/cache"
        p = {:url => doc_url,
             :accessKey => 2467,
             :landscape => (orientierung == "landscape" ? true : false),
             :printBackground => true,
             :pageSize => format,
             :marginsType => 1
        }
        File.open(file, 'w') {|f|
          block = proc { |response|
            response.read_body do |chunk|
              f.write chunk
            end
          }
          RestClient::Request.new(:method => :get,
                                  :url => 'pdf:3000/pdf',
                                  :headers => {:params => p},
                                  :block_response => block)
            .execute
        }
      rescue Exception => e
        puts "\n#{e}"
        halt 500, "Es ist kein PDF-Renderer konfiguriert."
      end
      send_file file, :type => :pdf
    end

    get '/suche/schueler/autocomplete.json' do
      content_type :json
      lit = Sequel.lit("Name LIKE :name OR Vorname LIKE :name", {:name=> "#{params[:pattern]}%"})
      schueler = Schueler.where(lit).limit(30)
      if schueler.empty?
        halt 404
      else
        schueler = schueler.map{ |s| { :value => "#{s.name}, #{s.vorname} (#{s.klasse})",
                                       :status => s.status, :jahr => s.akt_schuljahr,
                                       :link => "/auswahl/schueler/#{s.akt_schuljahr}/#{s.akt_abschnitt}/#{s.id}"}
        }.to_json
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
            ss = schueler.max_by{ |s| s.akt_schuljahr+s.akt_abschnitt }
            {:value => "#{klasse} (#{schueler.count{|s| s.status == 2}})",
             :link => "/auswahl/klasse/#{ss.akt_schuljahr}/#{ss.akt_abschnitt}/#{schueler.map{|s|s.id}.join(",")}"}
          end
        end
        ret.flatten.to_json
      end
    end

    get '/suche/:jahr/:abschnitt/:klasse' do
      klasse = Abschnitt.where(:Klasse => params[:klasse],
                               :Jahr => params[:jahr],
                               :Abschnitt => params[:abschnitt]).select(:Schueler_ID).all.map{|k|k.schueler_id}
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
      Presenters::Warnung.uniq.to_json
    end

    get '/ping' do
      status 200
    end

    get '/restart' do
      restart
    end

    get '/cache' do
      settings.config[:cache]
    end

    get '/auswahl/:doc/?:jahr?/?:abschnitt?/:id/?*' do
      schueler_gruppe= Schueler.where(:ID => Array(params[:id].split(","))) #kein [], weil hier mit Dataset gearbeitet wird!
      klasse = Presenters::KlassenPresenter.new(schueler_gruppe)
      halt 404, "Keine Schüler gefunden" if klasse.empty?
      klassenbezeichnung = params[:klasse] || klasse.first.halbjahr(params[:jahr], params[:abschnitt]).klasse
      klassenbezeichnung = klasse.s.klasse if klassenbezeichnung.nil?
      versetzung = Versetzung.eager(:fachklasse).first(:Klasse => klassenbezeichnung)
      abschnitt = (params[:abschnitt] ? params[:abschnitt].to_i : klasse.s.akt_abschnitt)
      slim params[:doc].to_sym, :locals => { :klasse => klasse,
                                             :dokumente => dokumente(settings.repos, klasse.s.asd_schulform[0], abschnitt),
                                             :jahr => (params[:jahr] ? params[:jahr].to_i : klasse.s.akt_schuljahr),
                                             :abschnitt => abschnitt,
                                             :versetzung => versetzung}
    end
  end

  module SahibRepo
    extend Sinatra::Extension
    helpers Helpers

    helpers do
      # damit PDF mit relativen Pfaden aus gecacheten Daten erstellt werden
      # können, müssen Links zu CSS etc relativ sein.
      def url(url)
        super(url, false)
      end
    end

    get '/css/:file.css' do
      scss params[:file].intern
    end

    before do
      Presenters::Warnung.flush
    end

    get '/:doc/:jahr/:abschnitt/:id/?*' do
      schueler = Schueler.eager(:fachklasse).where(:ID => Array(params[:id].split(","))) #kein [], weil hier mit Dataset gearbeitet wird!
      halt 404, "Keine Schüler gefunden" if schueler.count == 0
      doc = settings.repo.find{|d| d.document_key == params[:doc]}
      pass if doc.nil?
      settings.config.set :cache, slim(params[:doc].to_sym,
                                       :layout => doc.get("Layout"),
                                       :locals => { :schueler => Presenters::KlassenPresenter.new(schueler),
                                                    :jahr => (params[:jahr] ? params[:jahr].to_i : schueler.first.akt_schuljahr),
                                                    :abschnitt => (params[:abschnitt] ? params[:abschnitt].to_i : schueler.first.akt_abschnitt),
                                                    :doc => doc,
                                                    :repo => settings.repo})
    end
  end

  class SahibRepoAdmin < Sinatra::Application
    get '/repos' do
      slim :repos
    end

    get '/repos/update/all' do
      content_type :json
      settings.repos.all?{|r|r.update}.to_json
    end

    put '/repos/toggle-state' do
      content_type :json
      repo = settings.repos.find{|r|r.repo_name == params[:id]}
      repo_config = settings.config[:repos]
      repo_config[repo.location][:enabled] = !repo.enabled?
      (!!settings.config.set!(:repos, repo_config)).to_json
    end

    put '/repos/update' do
      content_type :json
      repo = settings.repos.find{|r|r.repo_name == params[:id]}
      repo.update.to_json
    end

    delete '/repos/delete' do
      content_type :json
      repo = settings.repos.find{|r|r.repo_name == params[:id]}
      if repo.is_a?(GitRepo) && Dir.exist?(repo.location+"/.git")
        `rm -rf "#{repo.location}"`
      end
      repo_config = settings.config[:repos]
      repo_config.delete repo.location
      (!!settings.config.set!(:repos, repo_config)).to_json
    end

    post '/repos/create' do
      content_type :json
      case params[:klass]
      when "GitRepo"
        begin
          print "Klone #{params[:origin]} nach #{settings.config[:repo_location]+"/"+params[:name]} … "
          repo = Git.clone(params[:origin], settings.config[:repo_location]+"/"+params[:name])
          puts "✓"
          location = repo.dir.path
        rescue Exception => e
          puts "\n#{e}"
          puts "✘ Klonen fehlgeschlagen"
          location = nil
          "false".to_json
        end
      when "LocalRepo"
        location = params[:origin]
      end
      if location
        repo_config = settings.config[:repos]
        repo_config[location] = {
          :klass => params[:klass],
          :origin => params[:origin],
          :enabled => true
        }
        (!!settings.config.set!(:repos, repo_config)).to_json
      end
    end
  end

  class << self
    def run_sahib
      @config = Daybreak::DB.new "./config/#{ENV['DATENBANK']}.db"
      at_exit {@config.close; puts "Konfigurationsdatenbank »#{ENV['DATENBANK']}« geschlossen"}

      if @config.empty?
        puts "Erstelle neue Konfigurationsdatenbank »#{ENV['DATENBANK']}«"
        # falls eine neue Config-Datenbank angelegt wurde, defaults setzen:
        @config.update! :repo_location => './plugins',
          :repos => {}
      else
        puts "Konfigurationsdatenbank »#{ENV['DATENBANK']}« wird verwendet"
      end

      repos = get_repos
      Sahib.set :repos => repos, :config => @config
      sahib = Sahib.new
      app_stack = [sahib] + create_sahib_repo_apps(repos).compact
      if ENV['S_REPO_ADMIN'] == "true"
        puts "Repository-Administration über die Weboberfläche ist zugelassen"
        SahibRepoAdmin.set :repos => repos, :config => @config
        app_stack.insert(1, SahibRepoAdmin.new)
      end
      Rack::Cascade.new (app_stack)
    end

    protected
    def get_repos
      return [] if @config[:repos].nil?
      repos = Array.new
      @config[:repos].each_pair do |location, options|
        if !options[:enabled]
          puts "#{location} deaktiviert"
          repos << RepoFactory.create("DisabledRepo", location, options)
          next
        end

        print "Prüfen, ob Repository #{location} verfügbar ist … "
        if !Dir.exist? location
          if options[:klass] == "GitRepo"
            puts "✘ nicht vorhanden."
            print "Klone Repository #{options[:origin]} nach #{location} … "
            begin
              Git.clone options[:origin], location
              puts "✓"
            rescue Exception => e
              puts "\n#{e}"
              puts "\nKlonen des Repositories fehlgeschlagen, Plugin nicht verfügbar"
            end
          end
        else
          puts "✓"
        end
        repos << RepoFactory.create(options[:klass], location, options)
      end
      repos
    end

    def create_sahib_repo_apps(repos)
      repos.map do |r|
        next unless r.enabled?
        if File.exist?(r.location+"/config.ru")
          create_sahib_plugin_app(r)
        else
          create_sahib_document_app(r)
        end
      end
    end

    def create_sahib_plugin_app(repo)
      repo.category = :app
      Rack::Builder.new do
        map('/app/'+File.basename(repo.repo_name)) do
          begin
            run Rack::Builder.parse_file(repo.location+'/config.ru').first
          rescue
            puts "Repository »"+repo.repo_name+"« fehlerhaft, konnte nicht starten."
            repo.enabled = false
            repo.category = :error
            return nil
          end
        end
      end.to_app
    end

    def create_sahib_document_app(repo)
      repo.category = :doc
      config = @config
      Rack::Builder.new do
        map('/dokumente/'+repo.repo_name) do
          repo_app = Sinatra.new do
            register SahibRepo
            set :repo, repo
            set :config, config
            set :views, [repo.location, repo.location+'/partials',
                         repo.location+'/views', repo.location+'/views/partials',
                         'views']
            set :public_folder, repo.location+"/public"
            set :logging, true
            if File.exist?(repo.location+"/lib/helpers.rb")
              puts "Modul »Helpers« vorhanden, wird eingebunden."
              require repo.location+"/lib/helpers"
              helpers Helpers
            end
          end
          run repo_app
        end
      end.to_app
    end
  end
end
