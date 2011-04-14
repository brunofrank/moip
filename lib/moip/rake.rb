module Moip
  module Rake
    extend self

    def run
      require "digest/md5"
      require "faker"

      # Not running in developer mode? Exit!
      unless Moip.developer?
        puts "=> [Moip] Can only notify development URLs"
        puts "=> [Moip] Double check your config/moip.yml file"
        exit
      end
      
      # There's no configuration file! Exit!
      unless File.exist?(MoipDeveloperController::MOIP_ORDERS_FILE)
        puts "=> [Moip] No orders added. Exiting now!"
        exit
      end

      # Load the orders file
      orders = YAML.load_file(MoipDeveloperController::MOIP_ORDERS_FILE)
      
      # Ops! No orders added! Exit!
      unless orders
        puts "=> [Moip] No invoices created. Exiting now!"
        exit
      end
      
      # Get the specified order
      order = orders[ENV["ID"]]
      
      # Not again! No order! Exit!
      unless order
        puts "=> [Moip] The order #{ENV['ID'].inspect} could not be found. Exiting now!"
        exit
      end
      
      # Replace the order id to the correct name
      order["id_transacao"] = order.delete("id_transacao")
      
      # Retrieve the specified status or default to :completed
      status = ENV["STATUS"] || '4'
      
      # Retrieve the specified payment method or default to :credit_card
      payment_method = ENV["PAYMENT_METHOD"] || 'CartaoDeCredito'
      
      # Set payment method and status
      order["tipo_pagamento"] = Moip::Notification::PAYMENT_METHOD.index(payment_method)
      order["status_pagamento"] = Moip::Notification::STATUS.index(status)
            
      # Set a random transaction id
      order["cod_moip"] = Digest::MD5.hexdigest(Time.now.to_s)
      
      # Finally, ping the configured return URL
      uri = URI.parse File.join(Moip.config["base"], Moip.config["return_to"])
      Net::HTTP.post_form uri, order
    end
  end
end
