require "#{File.dirname(__FILE__)}/spec_helper"
include SpecHelper
include Presenters

describe "Presenter" do
  describe 'Typesaver' do
    before do
      Warnung.flush
      vorhandener_schueler = nil
      until vorhandener_schueler
        vorhandener_schueler = Schueler[rand Schueler.count-1]
        @s=SchuelerPresenter.new(vorhandener_schueler)
      end
    end

    it "alle Methoden werden gesichert mit snake case ohne nil" do
       Schueler.columns.reject {|c| @s.send c.snake_case}.count.must_equal 0
       @s._geburtsdatum.must_be_nil
    end

    it 'bei fehlenden Werten wird ein String in der Warnklasse abgelegt' do
      @s.geburtsdatum
      Warnung.list[@s.name].must_equal ["<em>geburtsdatum</em> fehlt"]
    end

    it 'kann auch Null zurückgeben, wenn trotzdem nil kommt, z.B. Assoc' do
      @s.abi_abschluss.must_be_instance_of Presenters::StringSaver::Null
    end
  end

  describe "Warnung" do
    before do
      Warnung.flush
    end

    it 'Warnung hinzufügen' do
      Warnung.add("Jens", "Gibts nicht").must_equal("Gibts nicht")
    end

    it 'Warnungen werden gespeichert' do
      Warnung.add("Jens", "Gibts nicht mehr")
      Warnung.list.must_equal({"Jens" => ["Gibts nicht mehr"]})
    end

    it 'Warnungen geben nur einmal den Namen zurück' do
      Warnung.add "Kalle", "Wolle"
      Warnung.add "Kalle", "Mehl"
      Warnung.uniq.must_equal({"Kalle" => ["Wolle", "Mehl"]})
    end

    it 'flusht Warnungen' do
      Warnung.add "Kalle", "Wolle"
      Warnung.add "Kalle", "Mehl"
      Warnung.flush.must_equal({"Kalle" => ["Wolle", "Mehl"]})
      Warnung.list.must_be_nil
    end
  end
end
