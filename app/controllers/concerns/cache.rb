class Cache
  def before(controller)
    controller.expires_in 1.day, :public => true
  end
end
