class Login
  def before(controller)
    controller.user = User.parse_token(controller.request.headers['X-4S-Token'])
    unless controller.user
      raise ActionController::Unauthorized.new
    end
  end
end
