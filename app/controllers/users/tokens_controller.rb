module Users
  class TokensController < ApplicationController
    def renew
      user = decode_token!
      warden.set_user(user, scope: :user, store: false)
      render json: {
        status: { code: 200, message: 'Token renewed successfully.' }
      }, status: :ok
    rescue JWT::DecodeError
      render json: {
        error: { code: 401, message: 'Invalid or expired token.' }
      }, status: :unauthorized
    end

    private

    def decode_token!
      token = request.headers['Authorization'].to_s.delete_prefix('Bearer ').strip
      Warden::JWTAuth::UserDecoder.new.call(token, Devise.mappings[:user].name, nil)
    end
  end
end