class ApplicationController < ActionController::Base
  include ErrorHandlers
  attr_accessor :user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def error(code, status = 400)
    message = I18n.t "errors.code.#{code}"
    render :json => { error: { status: status, code: code, message: message } }, status: status
  end
end
