class UserController < ApplicationController
  before_action Login.new

  def show
    render :json => { email: user.email, image: user.image, identifier: user.identifier }
  end
end
