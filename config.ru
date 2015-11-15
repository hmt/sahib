require 'envyable'
CONFIG_FILE = ENV['CONFIG_FILE'] || './config/env_example.yml'
Envyable.load(CONFIG_FILE, ENV['RACK_ENV'])
ENV['S_ADAPTER'] = "jdbc:mysql" if RUBY_ENGINE == 'jruby'

require "#{File.dirname(__FILE__)}/sahib"
run Sinatra::Application
