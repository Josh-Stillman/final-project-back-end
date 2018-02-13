class UsersController < ApplicationController

  def matched_transactions
    #filter transactions by user
    #filter transactions by analyzed months -- model method to return this array
    #subsequent model method to spit out matched transactions.

    #also need to get the business for each matched transaction
    #then include nested business
    me = User.find(params[:id])
    @transactions = me.matched_transactions
    render json: @transactions.order(date: :desc), user_id: params[:id]

  end

  def unmatched_transactions
    me = User.find(params[:id])
    @transactions = me.matched_untransactions
    render json: @transactions.order(date: :desc), user_id: params[:id]
  end

  def load_new_month
    me = User.find(params[:id])
    if me.load_new_month
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def businesses
    me = User.find(params[:id])
    @businesses = me.businesses
    render json: @businesses.where.not(id: 1), each_serializer: MatchedBusinessSerializer, user_id: 1
  end

  def show
    @user = User.find(params[:id])
    render json: @user, each_serializer: UserSerializer
  end

  def create

    @user = User.new(name: params[:username], password: params[:password])

    if @user.valid?
      @user.save
      render json: @user
    else
      render json: {errors: @user.errors.full_messages}
    end
    #@user.valid? ? render json: @user : render json: @user.errors.messages
    #render json: @user
  end

  private

  def user_params
    params.require(:username, :password)
  end


end
