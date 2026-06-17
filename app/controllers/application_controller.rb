class ApplicationController < ActionController::Base
  # Include Pagy backend — adds pagination methods to all controllers
  include Pagy::Backend
end