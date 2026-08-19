class Api::V1::SettingsController < Api::V1::BaseController
  def show
    render json: {
      data: {
        ai_api_key: current_user.ai_api_key.present? ? "••••••••" : nil,
        ai_api_endpoint: current_user.ai_api_endpoint,
        has_api_key: current_user.ai_api_key.present?
      }
    }
  end

  def update
    if current_user.update(settings_params)
      render json: { data: { message: "Settings updated." } }
    else
      render json: { error: { code: 422, message: current_user.errors.full_messages.to_sentence } }, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:settings).permit(:ai_api_key, :ai_api_endpoint)
  end
end
