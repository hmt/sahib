require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'

ENV["CONFIG_FILE"] = "#{File.dirname(__FILE__)}/../config/env_example.yml"

SAHIB_APP = Rack::Builder.parse_file("#{File.dirname(__FILE__)}/../config.ru").first

module SpecHelper
  include Rack::Test::Methods
  def app
    SAHIB_APP
  end

  def session
    last_request.env['rack.session']
  end
end
