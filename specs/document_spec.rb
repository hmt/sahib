require "#{File.dirname(__FILE__)}/spec_helper"
include SpecHelper

describe "Dokumentenklassen" do
  describe "Dokumente" do
    before do
      @dokument = Document.new("#{File.dirname(__FILE__)}/doks/first.slim")
    end

    it "ist Document class" do
      @dokument.must_be_instance_of Document
    end

    it "holt mir einen Key" do
      @dokument.get('Format').must_equal "A4"
    end

    it "holt mir default-Werte" do
      @dokument.get("Test").must_equal "Default"
    end

    it "holt mir default-Werte bei Doc ohne config" do
      dokument = Document.new("#{File.dirname(__FILE__)}/doks/third.slim")
      dokument.get("Deckblatt").must_equal "deckblatt_dummy.svg"
    end

    it "parst die config" do
      @dokument.config_parser.must_be_instance_of Hash
    end
  end

  describe "Default Dokumente" do
    it "gibt Default Dokumente" do
      Document.new.must_be_instance_of Document
    end

    it "gibt Default configs" do
      Document.new.get("Test").must_equal "Default"
    end

    it "gibt auch default ohne new" do
      Document.default("Test").must_equal "Default"
    end
  end
end
