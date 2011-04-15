module Moip
  class Notification

    # Map all the attributes from PagSeguro
    MAPPING = {
      :payment_method => "tipo_pagamento",
      :order_id       => "id_transacao",
      :status         => "status_pagamento",
      :transaction_id => "cod_moip",
      :value          => "valor"
    }

    # Map order status from PagSeguro
    STATUS = {
      "1"          => :approved,      
      "2"          => :pending,
      "4"          => :completed,
      "5"          => :canceled,
      "6"          => :verifying,
      "7"          => :refunded
    }

    # Map payment method from PagSeguro
    PAYMENT_METHOD = {
      "CartaoDeCredito"       => :credit_card,
      "CartaoDeDebito"        => :credit_card,
      "BoletoBancario"        => :invoice,
      "CarteiraMoIP"          => :moip,
      "DebitoBancario"        => :online_transfer,
      "FinanciamentoBancario" => :online_transfer
    }

    # The Rails params hash
    attr_accessor :params

    # Expects the params object from the current request
    def initialize(params)
      @params = normalize(params)
    end

    # Normalize the specified hash converting all data to UTF-8
    def normalize(hash)
      each_value(hash) do |value|
        value.to_s.unpack('C*').pack('U*')
      end
    end

    # Denormalize the specified hash converting all data to ISO-8859-1
    def denormalize(hash)
      each_value(hash) do |value|
        value.to_s.unpack('U*').pack('C*')
      end
    end

    # Return the order status
    # Will be mapped to the STATUS constant
    def status
      @status ||= STATUS[mapping_for(:status)]
    end

    # Return the payment method
    # Will be mapped to the PAYMENT_METHOD constant
    def payment_method
      @payment_method ||= PAYMENT_METHOD[mapping_for(:payment_method)]
    end

    # Return the buyer info
    def buyer
      @buyer ||= {
        :email   => params["email_consumidor"]
      }
    end

    def method_missing(method, *args)
      return mapping_for(method) if MAPPING[method]
      super
    end

    # A wrapper to the params hash,
    # sanitizing the return to symbols
    def mapping_for(name)
      params[MAPPING[name]]
    end    

    private
      def each_value(hash, &blk)
        hash.each do |key, value|
          if value.kind_of?(Hash)
            hash[key] = each_value(value, &blk)
          else
            hash[key] = blk.call value
          end
        end

        hash
      end

      # Convert amount format to float
      def to_price(amount)
        amount.to_s.gsub(/[^\d]/, "").gsub(/^(\d+)(\d{2})$/, '\1.\2').to_f
      end


  end
end
