module Api
  module V1
    class BaseController < ApplicationController
      before_action -> { head(:forbidden) unless user_signed_in? }
    end
  end
end
