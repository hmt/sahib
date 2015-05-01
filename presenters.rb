module Presenters
  class SchuelerPresenter
    def initialize(s)
      @s = s
      @yaml = YAML.load_file('./config/strings.yml')
    end

    def klasse
      @s.first.Klasse
    end

    def akt_jahr
      @s.first.akt_schuljahr
    end
    alias :akt_schuljahr :akt_jahr

    def akt_abschnitt
      @s.first.akt_abschnitt
    end
    alias :akt_halbjahr :akt_abschnitt

    def abschnitte
      AbschnittePresenter.new(@s.first).jahr_und_abschnitt.reverse
    end

    def bildungsgang
      @yaml[@s.first.ASDSchulform]['Schulform'] rescue "Bildungsgang '#{@s.first.ASDSchulform}' in config/strings.yml anlegen"
    end

    def anzahl
      @s.count
    end

    def klassenlehrer
      a = @s.first.akt_halbjahr
      "#{a.klassenlehrer_in}: #{a.v_name_klassenlehrer}"
    end

    def schueler_details(schueler)
      schueler.map{ |s| {:name => s.name,
                         :vorname => s.vorname,
                         :adresse => "#{s.strasse}, #{s.plz} #{s.ort_abk}",
                         :telefon => s.telefon,
                         :geburtsdatum => s.geburtsdatum.strftime("%d.%m.%Y"),
                         :volljaehrig => s.volljaehrig?,
                         :id => s.id}}
    end

    def aktive_schueler
      @s.where(:Status => 2, :Geloescht => "-", :Gesperrt => "-")
    end

    def inaktive_schueler
      @s.exclude(:Status => 2)
    end
  end

  class AbschnittePresenter
    def initialize(s)
      @abschnitte = s.abschnitte_dataset
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
end
