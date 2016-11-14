require 'oga'
require 'slim/erb_converter'
require 'json'

class Document
  # Die Basiseinstellungen für Dokumente sind als "default" abgelegt, z.B. Logos etc
  #
  # Einzelne Dokumente:
  # Jedes Dokument sollte ein Element mit der id "#doc-einstellungen" haben,
  # das ein "data-json"-Attribut mit allen für das Dokument wichtigen
  # Einstellungen enthält. Im Nachfolgenden die möglichen Optionen:
  #
  # Name: Name des Dokuments, wie er in der Dokumentenerstellungsansicht gezeigt wird
  # Gruppen: Array mit Gruppen, die über asd_schulform[1] ermittelt werden (APO-BK Anlagen)
  # Format: ist für den Druck, A4, A3 etc
  # Orientierung: ist entweder portrait oder landscape - also hochkant oder quer im Format
  #   Standard für Format und Orientierung sind A4 und portrait
  #
  # Wird ein Hash mit Jahreszahlen angegeben, dann entscheidet das Jahr über die Verwendung
  # des Werts beim Druck. Zeugnisse aus 2013 verwenden z.B. den Wert, der >= 2013 gilt.
  #
  @@config = Hash.new
  @@config["default"] = {
    "logo_top"=>{
      2013=>"logo_top_dummy.svg",
      2014=>"logo_top_dummy.svg"
    },
    "logo_seite"=>"logo_seite_dummy.svg",
    "Deckblatt"=>"deckblatt_dummy.svg",
    "Format"=>"A4",
    "Orientierung"=>"portrait",
    "Gruppen"=>[],
    "Name"=>"Dokument",
    "Test"=>"Default",
    "Layout"=>true
  }

  attr_reader :config
  attr_reader :document_key
  attr_reader :file_name

  def self.default(key=nil, jahr=nil)
    key ? self.new.get(key, jahr) : self.new
  end

  def initialize(file_name=nil)
    if file_name
      @file_name = file_name
      @document_key = File.basename(file_name, '.slim')
      @config = config_parser
    else
      @config = {}
    end
  end

  # ein slim-Template in erb umwandeln und auf configs parsen. Hash wird zurückgegeben
  def config_parser
    template = File.open(@file_name)
    erb_file = Slim::ERBConverter.new.call(template.read)
    begin
      # template mit config-daten
      JSON.load(Oga.parse_html(erb_file).css("#doc-einstellungen").first.attr("data-json").value)
    rescue
      {"Name" => @document_key}
    end
  end

  def get(key, jahr=nil)
    string = @config.fetch(key, @@config["default"].fetch(key, nil))
    if string.class == Hash
      zul_jahr = string.keys.sort.reverse
      treffer = (jahr ? zul_jahr.find{|j| j <= jahr} : zul_jahr.first)
      string = string[treffer]
    end
    string
  end

  def verfuegbar(gruppe)
    get('Gruppen').empty? || get('Gruppen').include?(gruppe)
  end
end
