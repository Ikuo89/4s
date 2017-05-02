class ActionController::Forbidden < ActionController::ActionControllerError; end
class ActionController::Unauthorized < ActionController::ActionControllerError; end
class ActionController::BadRequest < ActionController::ActionControllerError; end

module ErrorHandlers
  extend ActiveSupport::Concern

  included do
    if Rails.env.production?
      rescue_from Exception, with: :rescue500
    end
    rescue_from ActionController::BadRequest, with: :rescue400
    rescue_from ActionController::Unauthorized, with: :rescue401
    rescue_from ActionController::Forbidden, with: :rescue403
    rescue_from ActionController::RoutingError, with: :rescue404
    rescue_from ActiveRecord::RecordNotFound, with: :rescue404
  end

  private
    def rescue500(e)
      @exception = e
      Rails.logger.error e
      # ExceptionMailer.notify(e).deliver_now
      render :json => {error: {status: 500, message: 'internal server error'}}, status: 500
    end

    def rescue400(e)
      @exception = e
      render :json => {error: {status: 400, message: 'bad request'}}, status: 400
    end

    def rescue401(e)
      @exception = e
      render :json => {error: {status: 401, message: 'unauthorized'}}, status: 401
    end

    def rescue403(e)
      @exception = e
      render :json => {error: {status: 403, message: 'forbidden'}}, status: 403
    end

    def rescue404(e)
      @exception = e
      render :json => {error: {status: 404, message: 'not found'}}, status: 404
    end
end
