class Api::V1::BaseController < ApplicationController
  before_action :validate_username

  attr_reader :current_user

  private def validate_username
    username = request.headers["X-USERNAME"]
    raise AuthenticationError::MissingUsername if username.blank?

    @current_user = User.find_by(name: username)
    raise AuthenticationError::UserNotFound if @current_user.blank?
  end
end
