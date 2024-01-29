# frozen_string_literal: true

class ErrorsController < ApplicationController
  def route_not_found
    redirect_to root_url, alert: 'Route not found'
  end
end
