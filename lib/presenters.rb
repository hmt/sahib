module Presenters
  module StringSaver
    # wird das Modul eingebunden, holt es für die delegierten Objekte erstmal
    # alle Infos über +super+ und legt anschließend für alle über
    # MethodLogger::Methods gespeicherten Methoden neue Filter an.
    # jeweils eine mit Unterstrich _ und eine identische. Erstere gibt auch nil
    # zurück, sinnvoll für if etc. Letztere legt, wenn leer oder nil, eine
    # Warnung unter Warnung ab. Kann dann im Layout per Javascript
    # abgefragt werden und als Zusatzinfo eingeblendet werden.
    # Sinnvoll, wenn z.B. Felder in Schild leer sind, die bei Dokumenten nicht
    # leer sein dürfen.
    def initialize(*)
      super
      return if __getobj__.nil?
      MethodLogger::Methods.list(__getobj__.class).each do |meth|
        ret = __getobj__.send(meth)
        define_singleton_method(meth) { __getobj__.send(meth, true) || meth_warnung(meth, ret) }
      end

      __getobj__.class.associations.each do |meth|
        ret = __getobj__.send(meth)
        define_singleton_method(meth) { __getobj__.send(meth) || meth_warnung(meth, ret) }
      end
    end

    def meth_warnung(meth=nil, ret=nil)
      return ret if meth == "zeugnis_bem"
      if [String, Time, Integer].include? ret.class
        Warnung.add(schueler.name, warn_string(meth))
        ret
      else
        Null::Object.instance
      end
    end

    def warn_string(meth)
      case meth
      when "klassenlehrer" then "Kein <em>Klassenlehrer</em> angegeben"
      when "konferenzdatum" then "Kein <em>Konferenzdatum</em> angegeben"
      when "zeugnis_datum" then "Kein <em>Zeugnisdatum</em> angegeben"
      when "entlassdatum" then "Kein <em>Entlassdatum</em> angegeben"
      when "bk_abschluss" then "Keine <em>Abschlussprüfung</em> in Schild durchgeführt"
      when "sum_fehl_std" then "Keine <em>Fehlstunden</em> angegeben"
      when "sum_fehl_std_u" then "Statt 0 wurden das Feld für unentschuldigte Fehlstunden freigelassen - es wird 0 eingesetzt"
      else "<em>#{meth.to_s}</em> fehlt"
      end
    end
  end

  class Warnung
    @@warnungen = {}

    def self.add(name, meldung)
      @@warnungen[name] ||= []
      @@warnungen[name] << meldung
      meldung
    end

    def self.list
      @@warnungen.empty? ? nil : @@warnungen
    end

    def self.uniq
      @@warnungen.merge!(@@warnungen){ |k,v| v.uniq }
    end

    def self.flush
      ret = self.uniq.dup
      @@warnungen.clear
      ret
    end
  end

  class SimpleDelegatorWrapper < SimpleDelegator
    include Presenters::StringSaver
  end

  class AbschnittPresenter < SimpleDelegatorWrapper
    def versetzungsvermerk(art=nil)
      # AGZ und Entlassdatum vor Juni, dann kein Vermerk (Juni ist willkürlich gewählt)
      return if art == :agz && self.schueler.entlassdatum.month < 6
      if abschnitt == 2 || (abschnitt == 1 && klasse.start_with?("H"))
        case self.VersetzungKrz
        when nil then "Kein Versetzungsvermerk hinterlegt"
        when "N" then "Nicht versetzt laut Konferenzbeschluss vom #{(konferenzdatum).strftime("%d.%m.%Y")}"
        when "V" then "Versetzt laut Konferenzbeschluss vom #{(konferenzdatum).strftime("%d.%m.%Y")}"
        end
      end
    end

    def bemerkungen
      # sollte nach Abschnitt udn Versetzung suchen und entscheiden. Korrigieren 28.6.16
      bemerkung = zeugnis_bem.gsub("\r\n","<br/>")
      bemerkung = 'keine' if bemerkung.empty?
      return bemerkung
    end
  end

  class SchuelerPresenter < SimpleDelegatorWrapper
    def halbjahr(jahr, abschnitt)
      case hj = __getobj__.halbjahr(jahr, abschnitt)
      when nil then Null::Object.instance
      else AbschnittPresenter.new(hj)
      end
    end

    def schueler_studierende
      if asd_schulform.start_with? "E"
        studierende_r
      else
        schueler_in
      end
    end

    def adresse
      "#{strasse}, #{plz} #{ort_abk}"
    end

    # Ein Hash erstellen mit den Fächern als Key
    # jeder Abschnitt hat einen Zähler i
    # Noten werden in ein Array nach i zugeordnet
    # und dienen dem Hash als Value
    def noten_hash
      liste = {}
      self.abschnitte.each_with_index do |a,i|
        a.noten.each do |n|
          liste[n.fach.fach_krz.to_sym] ||= Array.new(abschnitte.count, " ")
          liste[n.fach.fach_krz.to_sym][i] = n.noten_krz
        end
      end
      return liste
    end

    def schueler
      self
    end

    def alter
      ((Time.now - geburtsdatum.to_time)/(60*60*24*365)).floor
    end

    def monate_bis_18
      date1 = Time.now
      date2 = geburtsdatum+(31556926*18)
      monate = (date2.year - date1.year) * 12 + date2.month - date1.month - (date2.day >= date1.day ? 0 : 1)
      monate <= 0 ? nil : monate
    end

    def note_in_worten(note)
      return if note.nil?
      zahlwort={1=>"eins",2=>"zwei",3=>"drei",4=>"vier",5=>"fünf",6=>"sechs",7=>"sieben",8=>"acht",9=>"neun",0=>"null"}
      note.split("").map{|n|n=="," ? "/" : zahlwort[n.to_i]}.join(" ")
    end

    def durchschnittsnote_fhr_in_worten
      note_in_worten durchschnittsnote_fhr
    end

    def daten_vollstaendig?(daten=[], warnung="")
      vollstaendig = daten.all?
      Warnung.add(name, warnung) unless vollstaendig
      vollstaendig
    end
  end

  class KlassenPresenter
    include Enumerable
    attr_reader :s

    def initialize(k)
      return if k.empty?
      @k = k.order(:Name)
      @s = SchuelerPresenter.new(@k.find{|s| ([2,8].include? s.status) && (s.geloescht == "-") && (s.gesperrt == "-")} || @k.first)
    end

    def each
      @k && @k.each{ |s| yield SchuelerPresenter.new(s) }
    end

    def empty?
      self.count == 0
    end

    def alle_schueler
      self.class.new @k.where(:Geloescht => "-", :Gesperrt => "-")
    end

    def aktive_schueler
      self.class.new @k.where(:Status => [2, 8], :Geloescht => "-", :Gesperrt => "-")
    end

    def inaktive_schueler
      self.class.new @k.exclude(:Status => [2, 8])
    end

    def noten(jahr=akt_schuljahr, abschnitt=akt_abschnitt)
      liste = {:name => []}
      schueler = aktive_schueler
      schueler.each_with_index do |s,i|
        liste[:name][i] = s.name
        next if s.halbjahr(jahr, abschnitt).nil?
        s.halbjahr(jahr, abschnitt).noten.each do |n|
          liste[n.fach.fach_krz.to_sym] ||= Array.new(schueler.count, " ")
          liste[n.fach.fach_krz.to_sym][i] = n.noten_krz
        end
      end
      return liste
    end
  end
end
