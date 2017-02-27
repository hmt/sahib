require "#{File.dirname(__FILE__)}/spec_helper"
include SpecHelper

describe "Repo" do
  before do
    @r = RepoFactory.create("LocalRepo", "#{File.dirname(__FILE__)}/doks",{"origin" => "xx"})
  end

  it "ist eine Subclass" do
    @r.must_be_instance_of LocalRepo
  end

  it "alle Dokumente erfassen" do
    @r.documents.count.must_equal 3
  end

  it "ist enumerable und gibt Document zurück" do
    @r.first.must_be_instance_of Document
  end

  it "kann auf repo doc zugreifen" do
    authorize 'admin', ''
    get "/dokumente/#{@r.repo_name}/#{@r.documents.first.document_key}/2008/2/1"
    last_response.status.must_equal 200
  end
end

describe "Strings abfragen" do
  before do
    Warnung.flush
    @a = AbschnittPresenter.new(Schueler.first.halbjahr(2008,2))
    @r = RepoFactory.create("LocalRepo", "#{File.dirname(__FILE__)}/doks",{"origin" => "xx"})
  end

  it "gibt passende default strings aus yaml zurück" do
    @r.fachklasse_info(@a, "Bereich").must_equal "Bereich fehlt"
  end

  it "gibt passende default strings aus yaml zurück und warnt" do
    @r.fachklasse_info(@a, "Bereich")
    Warnung.list.must_equal({"Dokument"=>["Es sollten Einstellungen für den Bildungsgang 14-106-00 in der Datei config/strings.yml vorgenommen werden"]})
  end

  it "gibt Strings zurück" do
    @r.fachklasse_info(@a, "Berufsbezeichnung_m").must_equal "männliche Berufsbezeichnung"
  end

  it "gibt Strings nach Jahr zurück" do
    # da in der Testdatenbank keine Ausbildungsbeginnzeiten angegeben sind - skip
    skip
    @r.fachklasse_info(@a, "Berufsbezeichnung_w").must_equal "weibliche Berufsbezeichnung 2009"
  end

  it "gibt Strings nach Jahr nicht zurück, wenn das Jahr früher ist als zuerst verfügbar" do
    a = AbschnittPresenter.new(Schueler.first.halbjahr(2007,2))
    @r.fachklasse_info(a, "Berufsbezeichnung_w").must_include "String"
  end

  it "holt mir einen Textbaustein" do
    @r.textbaustein(@a, "APO").must_include "Berufskollegs"
  end
end
