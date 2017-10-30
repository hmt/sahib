require "#{File.dirname(__FILE__)}/spec_helper"
include SpecHelper

describe "routes" do
  describe "Views ok" do
    it "gibt repos 200 zurück" do
      get '/repos'
      last_response.status.must_equal 200
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
