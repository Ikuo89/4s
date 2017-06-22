class HealthcheckController < ApplicationController
  def check
    now = ActiveRecord::Base.connection.select_all "SELECT now() as now;"
    render :json => now[0]
  end
end
