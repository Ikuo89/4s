class ResourceController < ApplicationController
  layout false
  before_action Cache.new
  protect_from_forgery except: :error_message

  def error_message
    render :js => layout(JSON.generate(I18n.t("errors.code")))
  end

  private
    def layout(json)
      return "define(function () { return #{json} });"
    end
end
