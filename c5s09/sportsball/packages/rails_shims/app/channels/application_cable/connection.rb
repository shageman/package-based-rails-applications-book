module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = current_user
    end

    def session
      @request.session
    end

    private

    def current_user
      session[:current_user]
    end
  end
end

