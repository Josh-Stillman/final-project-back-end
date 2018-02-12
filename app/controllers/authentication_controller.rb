class AuthenticationController < ApplicationController

  def create
    user = User.find_by(name: params[:username])
    if user && user.authenticate(params[:password])
      render json: {
        id: user.id,
        username: user.name,
        jwt: JWT.encode({user_id: user.id}, ENV['pusher_secret'], 'HS256')
      }
    else
      render json: {error: 'User not found'}, status: 404
    end
  end

  def show
    if current_user
      render json: {
        id: current_user.id,
        username: current_user.name
      }
    else
      render json: {error: 'No id present on headers'}, status: 404
    end
  end
end
