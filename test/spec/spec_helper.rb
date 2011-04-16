ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require "spec"
require "spec/rails"

FakeWeb.allow_net_connect = false
