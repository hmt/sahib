ENV['RACK_ENV'] = 'testing'
require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'envyable'
CONFIG_FILE = ENV['CONFIG_FILE'] || './config/env_example.yml'
Envyable.load(CONFIG_FILE, ENV['RACK_ENV'])
ENV['S_ADAPTER'] = "jdbc:mysql" if RUBY_ENGINE == 'jruby'
require "#{File.dirname(__FILE__)}/../sahib"

module SpecHelper
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  def session
    last_request.env['rack.session']
  end
end
