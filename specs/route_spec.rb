require "#{File.dirname(__FILE__)}/spec_helper"
include SpecHelper

@dokumente = DokumentenSammlung.new(true)

describe "routes" do
  describe 'basic auth' do
    it "ohne auth" do
      get '/'
      last_response.status.must_equal 401
    end
    it "falsche auth" do
      authorize 'oh', 'ah'
      get '/'
      last_response.status.must_equal 401
    end
    it "korrekte auth" do
      authorize 'admin', ''
      get '/'
      last_response.status.must_equal 200
    end
  end

  describe "Views ok" do
    before do
      authorize 'admin', ''
    end

    it "gibt home-view 200 zurück" do
      get '/'
      last_response.status.must_equal 200
    end

    it "gibt alle schüler-views 200 zurück" do
      get '/schueler/1'
      last_response.status.must_equal 200
      get '/schueler/1/2008/2'
      last_response.status.must_equal 200
      get '/schueler/1/2007/2'
      last_response.status.must_equal 200
      get '/schueler/1/2007'
      last_response.status.must_equal 200
    end

    it "gibt alle klassen-views 200 zurück" do
      get '/klasse/FOS2/2008'
      last_response.status.must_equal 200
      get '/klasse/FOS2/2008/2'
      last_response.status.must_equal 200
      get '/klasse/FOB/2007/1'
      last_response.status.must_equal 200
    end
  end

  describe "Dokumente" do
    before do
      authorize 'admin', ''
    end

    DokumentenSammlung.new.each do |dokument|
      it "dokument #{dokument.name} gibt 200 zurück" do
        get "/dokumente/#{dokument.name}/2008/2/1,2"
        last_response.status.must_equal 200
        get "/dokumente/#{dokument.name}/2008/2/1"
        last_response.status.must_equal 200
      end
    end
  end
end
