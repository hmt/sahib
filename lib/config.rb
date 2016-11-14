require "yaml"
require "envyable"

class Config
  @@config_dir

  def self.docker?
    if File.exists?("/.dockerenv") && Dir.exists?("/sahib/config")
      @@config_dir = "/sahib/config"
      return true
    else
      @@config_dir = "./config"
      return false
    end
  end

  def self.load(optional_file=nil)
    file = get_config_file(optional_file)
    YAML.load_file(file)
  end

  def self.default
    load('./config/env_example.yml')['default']
  end

  def self.save(options, optional_file=nil)
    options["docker"] = self.docker?
    file = get_config_file(optional_file)
    if File.exist?(file)
      configuration = YAML.load_file(file)
      configuration[ENV['RACK_ENV']] = options
    else
      options = default.merge(options)
      configuration = {ENV['RACK_ENV'] => options}
    end
    File.open(file, 'w') { |f| YAML.dump(configuration, f) }
  end

  def self.update(options)
    file = get_config_file
    configuration = YAML.load_file(file)
    configuration[ENV['RACK_ENV']] = options
    open(file, 'w') { |f| YAML.dump(configuration, f) }
  end

  def self.get_config_file(optional_file=nil)
    if optional_file
      optional_file
    elsif ENV["CONFIG_FILE"]
      ENV["CONFIG_FILE"]
    elsif self.docker?
      @@config_dir+"/env_init.yml"
    else
      "./config/env_init.yml"
    end
  end

  def self.activate_config(file)
    Envyable.load(file, ENV['RACK_ENV']) && self.load(file)[ENV['RACK_ENV']]
  end
end
