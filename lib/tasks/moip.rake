namespace :moip do

  desc "Copy configuration file"
  task :setup do
    require "FileUtils" unless defined?(FileUtils)
    FileUtils.cp File.dirname(__FILE__) + "/../../templates/moip.yml", "config/moip.yml"

    puts "=> [Moip] Please edit 'config/moip.yml'"
  end
end
