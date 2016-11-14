require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require "#{File.dirname(__FILE__)}/../lib/config"

ENV['RACK_ENV'] = 'testing'

describe "Lesen der Config" do
  before do
    @config_file = "#{File.dirname(__FILE__)}/config/env_test.yml"
  end

  it "findet config file" do
    Config.get_config_file(@config_file).must_equal @config_file
  end

  it "aktiviert Config file" do
    config = Config.activate_config(@config_file)
    ENV["SAHIB_TEST"].must_equal "bababa"
    config['SAHIB_TEST'].must_equal "bababa"
  end
end

describe "schreiben der Config" do
  before do
    @config_file = "#{File.dirname(__FILE__)}/config/env_test.yml"
    @original = YAML.load_file(@config_file)
    Config.save({"SAHIB_TEST" => "bababa", "Testschrieb" => "hahaha"}, @config_file)
    Config.activate_config(@config_file)
  end

  after do
    open(@config_file, 'w') { |f| YAML.dump(@original, f) }
  end

  it "überschreibt nicht andere ENVs" do
    @original["production"]["SAHIB_TEST"].must_equal "gugugu"
  end

  it "schreibt config file" do
    ENV["Testschrieb"].must_equal "hahaha"
    ENV["SAHIB_TEST"].must_equal "bababa"
  end
end


