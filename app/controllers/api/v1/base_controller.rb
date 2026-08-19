class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def not_found(exception)
    render json: {
      error: {
        code: 404,
        message: exception.message
      }
    }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: {
      error: {
        code: 422,
        message: exception.record.errors.full_messages.to_sentence
      }
    }, status: :unprocessable_entity
  end
end
