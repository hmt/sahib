# Damit sahib starten kann, wird eine funktionierende Datenbankverbindung
# vorausgesetzt. Da es mehrere Möglichkeiten gibt, die Verbindungsdaten
# mitzuteilen, wird hier geprüft, ob Einstellungen vorhanden sind.
#
# In folgender Reihenfolge wird geprüft:
# Vorgabe durch Umgebungsvariablen beim Start
# Vorgabe durch externe, permanente Konfigurationsdatei
# Vorgabe durch lokale Umgebungsvariablen, z.B. in einer lokalen Datei
# Keine Vorgabe, Nutzerabfrage in eigener Instanz, ohne Anbindung zur Datenbank
# Anschließend ist ein Serverneustart intern erforderlich
#
require "sequel"
require "sinatra"
require "sinatra/extension"
require 'slim'
require 'sass'
require 'json'
require "#{File.dirname(__FILE__)}/lib/helpers"
require "#{File.dirname(__FILE__)}/lib/config"
require "#{File.dirname(__FILE__)}/lib/repo"

@config_file = Config.get_config_file

def db_test
  ENV['S_ADAPTER'] = "jdbc:mysql" if RUBY_ENGINE == 'jruby'
  begin
    @db = Sequel.connect("#{ENV['S_ADAPTER']}://#{ENV['S_HOST']}/#{ENV['S_DB']}?user=#{ENV['S_USER']}&password=#{ENV['S_PASSWORD']}&zeroDateTimeBehavior=convertToNull")
  rescue
    return false
  end
  @db.test_connection
end

def db_test_file
  return unless @config_file
  puts "#{@config_file} laden …"
  @config = Config.activate_config(@config_file)
  db_test
end

def get_repos
  return [] if @config['S_REPOS'].nil?
  repos = Array.new
  @config['S_REPOS'].each_pair do |location, options|
    if !options["enabled"]
      puts "#{location} deaktiviert"
      repos << RepoFactory.create("DisabledRepo", location, options)
      next
    end

    print "Prüfen, ob Repository #{location} verfügbar ist … "
    if !Dir.exist? location
      if options['klass'] == "GitRepo"
        puts "✘ nicht vorhanden."
        print "Klone Repository #{options['origin']} nach #{location} … "
        begin
          Git.clone options['origin'], location
          puts "✓"
        rescue
          puts "\nKlonen des Repositories fehlgeschlagen, Plugin nicht verfügbar"
        end
      end
    else
      puts "✓"
    end
    repos << RepoFactory.create(options['klass'], location, options)
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
      end
      run repo_app
    end
  end.to_app
end

def run_sahib
  require "#{File.dirname(__FILE__)}/sahib"
  repos = get_repos
  sahib = Sahib.new{set :repos => repos, :config => @config}
  app_stack = [sahib] + create_sahib_repo_apps(repos).compact
  if @config['S_REPO_ADMIN']
    puts "Repository-Administration über die Weboberfläche ist zugelassen"
    app_stack.insert(1, SahibRepoAdmin.new{set :repos, repos})
  end
  run Rack::Cascade.new (app_stack)
end

if db_test || db_test_file
  puts "Sahib starten …"
  @config ||= Config.load(@config_file)[ENV['RACK_ENV']]
  run_sahib
else
  puts "Keine Konfigurationsdatei gefunden, Sahib-Konfiguration starten …"
  require "#{File.dirname(__FILE__)}/init"
  run SahibInit
end

