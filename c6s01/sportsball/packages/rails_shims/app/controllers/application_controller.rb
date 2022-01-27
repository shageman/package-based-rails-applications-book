# typed: false
class ApplicationController < ActionController::Base
  append_view_path(Dir.glob(Rails.root.join('packages/*/app/views')))
end

