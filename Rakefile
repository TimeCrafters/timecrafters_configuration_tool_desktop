require "releasy"
require 'bundler/setup' # Releasy requires that your application uses bundler.
require_relative "lib/version"

Releasy::Project.new do
  name TAC::NAME
  version TAC::VERSION

  executable "timecrafters_configuration_tool.rb"
  files ["lib/**/*.*", "media/**/*.*", "data/.gitkeep", "data/configs/.gitkeep"]
  exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.
  verbose

  add_build :windows_folder do
    icon "media/icon.ico"
    executable_type :windows # Assuming you don't want it to run with a console window.
    add_package :exe # Windows self-extracting archive.
  end
end
