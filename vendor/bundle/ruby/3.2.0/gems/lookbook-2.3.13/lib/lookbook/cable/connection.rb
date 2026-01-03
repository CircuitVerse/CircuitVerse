module Lookbook
  class Connection < ActionCable::Connection::Base
    identified_by :uid

    def connect
      self.uid = request.params[:uid]
      logger.add_tags(uid)
      logger.info "connected to Lookbook"
    end
  end
end
