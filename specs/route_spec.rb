require "#{File.dirname(__FILE__)}/spec_helper"
include SpecHelper

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
      get '/auswahl/schueler/1'
      last_response.status.must_equal 200
      get '/auswahl/schueler/2008/2/1'
      last_response.status.must_equal 200
      get '/auswahl/schueler/2007/2/1'
      last_response.status.must_equal 200
      get '/auswahl/schueler/2007/1'
      last_response.status.must_equal 200
    end

    it "gibt alle klassen-views 200 zurück" do
      get '/auswahl/klasse/2008'
      last_response.status.must_equal 200
      get '/auswahl/klasse/2008/2'
      last_response.status.must_equal 200
      get '/auswahl/klasse/2007/1'
      last_response.status.must_equal 200
    end
  end
end
