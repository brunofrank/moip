class CartController < ApplicationController
  
  def success
    moip_notification do |n|
      Rails.logger.debug "==> #{n.inspect}"
    end
  end
  
  def index
    @order = Moip::Order.new("ABC")
    @order.add :id => 1, :price => 9.00, :description => "Ruby 1.9 PDF"
    @order.add :id => 2, :price => 12.50, :description => "Ruby 1.9 Screencast"
    @order.add :id => 3, :price => 19.90, :description => "Ruby T-Shirt", :weight => 300, :shipping => 2.50
  end
end
