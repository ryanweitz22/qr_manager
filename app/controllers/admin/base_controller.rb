# Every admin controller inherits from this class
# This means ALL admin pages automatically require login
# before_action :authenticate_admin_user! is provided by Devise
# It redirects to the login page if the admin is not signed in
class Admin::BaseController < ApplicationController
  before_action :authenticate_admin_user!
end