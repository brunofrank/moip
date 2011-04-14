module Moip
  module ActionController
    private
      def moip_notification(token = nil, &block)
        return unless request.post?
        
        _notification = Moip::Notification.new(params, token)
        yield _notification if _notification.valid?
      end
  end
end
