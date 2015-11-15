class DokumentenSammlung
  include Enumerable
  def initialize(alle=false)
    @dokumente = Dir["dokumente/*"].reject{|f| File.directory?(f) || !f[".slim"]}.map{|f| File.basename(f, '.slim')}
    @config = YAML.load_file('./config/doc_einstellungen.yml')
    @dokumente = @dokumente & @config.keys unless alle
  end

  def each
    @dokumente && @dokumente.each{ |d| yield Dokument.new(d) }
  end

end

class Dokument
  @@textbausteine = YAML.load_file('./config/textbausteine.yml')
  attr_reader :name

  def self.default(key=nil, jahr=nil)
    key ? self.new("default").get(key, jahr) : self.new("default")
  end

  def initialize(name)
    @config = YAML.load_file('./config/doc_einstellungen.yml')
    @name = name
  end

  def get(key, jahr=nil)
    string = @config[@name].fetch(key, false) || @config["default"].fetch(key, nil)
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

  def textbaustein(key)
    string = @@textbausteine['Textbausteine'][key]
    if string.class == Hash
      zul_jahr = string.keys.sort.reverse
      treffer = zul_jahr.find{|j| j <= self.jahr}
      string = string[treffer]
    end
    return "|"+string
  end
end
