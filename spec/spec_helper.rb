RAILS_ENV = "test"

require "rubygems"
require "spec"
require "fakeweb"
require File.dirname(__FILE__) + "/../lib/moip"

require "bigdecimal"

FakeWeb.allow_net_connect = false
PagSeguro::ORIGINAL_CONFIG_FILE = Moip::CONFIG_FILE
PagSeguro::CONFIG_FILE.gsub!(/^.*$/, File.dirname(__FILE__) + "/moip.yml")

class Object
  def self.unset_class(*args)
    class_eval do
      args.each do |klass|
        eval(klass) rescue nil
        remove_const(klass) if const_defined?(klass)
      end
    end
  end
end
