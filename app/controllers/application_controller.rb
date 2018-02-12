class ApplicationController < ActionController::API

    def current_user
      @user ||= User.find_by(id: user_id)
    end

    def user_id
      decoded_token.first['user_id']
    end

    def decoded_token
      begin
         JWT.decode(request.headers['Authorization'], ENV['pusher_secret'])
       rescue JWT::DecodeError
        [{}]
       end
    end

end
