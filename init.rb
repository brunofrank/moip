require File.dirname(__FILE__) + "/lib/moip"

if defined?(Rails)
  %w(action_controller_ext helper).each do |f|
    require File.dirname(__FILE__) + "/lib/moip/#{f}"
  end
  
  ActionView::Base.send(:include, MoipHelper)
  ActionController::Base.send(:include, Moip::ActionController)
end
