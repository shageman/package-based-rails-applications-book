class ApplicationController < ActionController::Base
  append_view_path(Dir.glob(Rails.root.join('packages/*/app/views')))
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
