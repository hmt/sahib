require 'git'
require 'yaml'
require "#{File.dirname(__FILE__)}/document"

class RepoFactory
  def self.create(klass, location, options)
    Object.const_get(klass).new(location, options)
  end
end

class Repo
  include Enumerable

  attr_reader :location
  attr_reader :origin
  attr_reader :documents
  attr_reader :repo_name
  attr_reader :klass
  attr_reader :fachklassen_strings
  attr_reader :textbausteine
  attr_accessor :category
  attr_accessor :enabled

  # Angabe des Pfads zum Repo
  def initialize(location, options)
    @location = location
    @origin = options[:origin]
    @repo_name = File.basename location
    @documents = get_repo_files
    @fachklassen_strings = get_fachklassen_strings
    @textbausteine = get_textbausteine
    @enabled = true
  end

  def check_and_load_yaml(files)
    file = files.find do |f|
      File.exist? f
    end
    YAML.load_file file if file
  end

  def abschnitt_fehlt
    Warnung.add "Dokument", "Schüler ohne Abschnitt. Fehler bei Bildungsgang/Textbausteinen"
    nil
  end

  def get_textbausteine
    f1 = @location+"/config/textbausteine.yml"
    f2 = @location+"/textbausteine.yml"
    check_and_load_yaml([f1, f2])
  end

  def textbaustein(abschnitt, key)
    return abschnitt_fehlt if abschnitt.nil?
    string = @textbausteine['Textbausteine'][key]
    if string.class == Hash
      zul_jahr = string.keys.sort.reverse
      treffer = zul_jahr.find{|j| j <= abschnitt.jahr}
      string = string[treffer]
    end
    return "|"+string
  end

  def get_fachklassen_strings
    f1 = @location+"/config/fachklassen.yml"
    f2 = @location+"/fachklassen.yml"
    check_and_load_yaml([f1, f2])
  end

  def fachklasse_info(abschnitt, *keys)
    return abschnitt_fehlt if abschnitt.nil?
    if abschnitt.fachklasse.nil?
      Warnung.add(abschnitt.schueler.name, "Schüler#{abschnitt.schueler.geschlecht == 3 ? "":"in"} ist keiner Fachklasse zugeordnet")
      return "Fachklasse nicht angegeben"
    end
    kennung = abschnitt.fachklasse && abschnitt.fachklasse.kennung
    if @fachklassen_strings[kennung]
      string = @fachklassen_strings[kennung]
    else
      string = @fachklassen_strings["default"]
      Warnung.add("Dokument", "Es sollten Einstellungen für den Bildungsgang #{abschnitt.fachklasse.kennung} in der Datei config/strings.yml vorgenommen werden") if @fachklassen_strings[kennung].nil?
    end
    return if string[keys.first].nil?
    keys.each {|k| string = string.fetch(k,nil)}
    if string.class == Hash
      zul_jahr = string.keys.sort.reverse
      treffer = zul_jahr.find{|j| j <= abschnitt.schueler.beginn_bildungsgang.year}
      string = string[treffer] || Warnung.add("Bildungsgang", "Es wurde kein gültiges Jahr für diesen String gefunden. Bitte anlegen")
    end
    return string
  end

  # alle template-Dateien eines Repos zurückgeben
  def get_repo_files
    return [] if File.exist?(@location+"/plugin.rb") || File.exist?(@location+"/"+@repo_name+".rb")
    files = Array.new
    files += Dir[location+"/views/*"].reject{|f| File.directory?(f) || !f[".slim"] || f['layout.slim']}
    files += Dir[location+"/*"].reject{|f| File.directory?(f) || !f[".slim"] || f['layout.slim']}
    files.map{|f| Document.new f}
  end

  def update
    @dokumente = get_repo_files
  end

  def each
    @documents && @documents.each{ |d| yield d }
  end

  def enabled?
    @enabled
  end
end

class LocalRepo < Repo; end

class DisabledRepo
  attr_reader :location
  attr_reader :repo_name
  attr_reader :origin
  attr_reader :category

  def initialize(location, options)
    @location = location
    @enabled = false
    @category = :disabled
    @origin = options[:origin]
    @repo_name = File.basename location
  end

  def enabled?
    @enabled
  end
end

class GitRepo < Repo
  def initialize(location, options)
    @klass = :GitRepo
    super
  end

  def update
    g = Git.open @location
    g.pull
    super
  end
end

