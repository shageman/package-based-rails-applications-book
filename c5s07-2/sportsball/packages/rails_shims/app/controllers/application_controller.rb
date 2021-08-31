class ApplicationController < ActionController::Base
  append_view_path(Dir.glob(Rails.root.join("packages/*/app/views")))

  before_action :ensure_session

  def current_user
    session[:current_user]
  end

  private 
  
  def ensure_session
    session[:current_user] ||= "user_#{SecureRandom.uuid}"
  end
end

