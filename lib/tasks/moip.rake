namespace :moip do
  desc "Send notification to the URL specified in your config/moip.yml file"
  task :notify do
    require "config/environment"
    require File.dirname(__FILE__) + "/../../init"
    require File.dirname(__FILE__) + "/../moip/rake"
    Moip::Rake.run
  end

  desc "Copy configuration file"
  task :setup do
    require "FileUtils" unless defined?(FileUtils)
    FileUtils.cp File.dirname(__FILE__) + "/../../templates/moip.yml", "config/moip.yml"

    puts "=> [Moip] Please edit 'config/moip.yml'"
  end
end
