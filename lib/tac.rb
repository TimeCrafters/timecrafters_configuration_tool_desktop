module TAC
  if ARGV.join.include?("--dev")
    ROOT_PATH = File.expand_path("../..", __FILE__)
  else
    ROOT_PATH = "#{Dir.home}/TimeCrafters_Configuration_Tool"
  end
  CONFIGS_PATH = "#{ROOT_PATH}/data/configs"
  SETTINGS_PATH = "#{ROOT_PATH}/data/settings.json"

  MEDIA_PATH = "#{File.expand_path("../..", __FILE__)}/media"

  CONFIG_SPEC_VERSION = 2
end