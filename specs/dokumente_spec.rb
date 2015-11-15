require "#{File.dirname(__FILE__)}/spec_helper"
include SpecHelper

describe "Dokumentenklassen" do
  describe 'Dokumentensammlung kann erstellt werden' do
    it "alle Dokumente erfassen" do
      nur_dokumentierte_dokumente = DokumentenSammlung.new
      nur_dokumentierte_dokumente.count.must_be :>, 5
      alle_dokumente = DokumentenSammlung.new(true)
      alle_dokumente.count.must_be :>, 5
    end

    it 'Dokumente geben bei each ein Dokument zurück' do
      DokumentenSammlung.new.first.class.must_equal Dokument
    end
  end

  describe "Dokumente" do
    before do
      @dokument = DokumentenSammlung.new.first
    end

    it "hat einen Namen" do
      @dokument.name.class.must_equal String
    end

    it "holt mir einen Key" do
      @dokument.get('Format').must_equal "A4"
    end

    it "holt mir default-Werte" do
      @dokument.get("Test").must_equal "Default"
    end

    it "holt mir Keys nach Jahr" do
      Dokument.default("logo_top", 2013).must_equal "logo_top_dummy.svg"
    end

    it "holt mir die default Dokumenten-Einstellungen" do
      d=Dokument.default
      d.name.must_equal "default"
    end

    it "holt mir einen Textbaustein" do
      @dokument.textbaustein("APO").must_include "Berufskollegs"
    end

    it "holt mir verfügbare Gruppen aus default" do
      Dokument.default.verfuegbar("X").must_equal true
    end
  end
end
