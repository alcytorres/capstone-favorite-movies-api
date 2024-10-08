class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  def current_user
    auth_headers = request.headers["Authorization"]
    if auth_headers.present? && auth_headers[/(?<=\A(Bearer ))\S+\z/]
      token = auth_headers[/(?<=\A(Bearer ))\S+\z/]
      begin
        decoded_token = JWT.decode(
          token,
          Rails.application.credentials.fetch(:secret_key_base),
          true,
          { algorithm: "HS256" }
        )
        User.find_by(id: decoded_token[0]["user_id"])
      rescue JWT::ExpiredSignature
        nil
      end
    end
  end

  helper_method :current_user

  def authenticate_user
    unless current_user
      render json: {}, status: :unauthorized
    end
  end

end

  # def current_user
  #   auth_headers = request.headers['Authorization']
  #   Rails.logger.debug "Authorization Header: #{auth_headers}"

  #   if auth_headers.present? && auth_headers[/\ABearer (.+)\z/, 1]
  #     token = auth_headers[/\ABearer (.+)\z/, 1]
  #     Rails.logger.debug "Token: #{token}"

  #     begin
  #       decoded_token = JWT.decode(
  #         token,
  #         Rails.application.credentials.fetch(:secret_key_base),
  #         true,
  #         { algorithm: 'HS256' }
  #       )
  #       Rails.logger.debug "Decoded Token: #{decoded_token}"

  #       user_id = decoded_token[0]["user_id"]
  #       Rails.logger.debug "User ID from Token: #{user_id}"

  #       user = User.find_by(id: user_id)
  #       Rails.logger.debug "User Found: #{user.inspect}"

  #       user
  #     rescue JWT::ExpiredSignature
  #       Rails.logger.debug "Expired Token"
  #       nil
  #     rescue JWT::DecodeError => e
  #       Rails.logger.debug "Decode Error: #{e.message}"
  #       nil
  #     end
  #   end
  # end

  # def authenticate_user!
  #   unless current_user
  #     render json: {}, status: :unauthorized
  #   end
  # end
