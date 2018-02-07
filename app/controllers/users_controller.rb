class UsersController < ApplicationController

  def matched_transactions
    #filter transactions by user
    #filter transactions by analyzed months -- model method to return this array
    #subsequent model method to spit out matched transactions.

    #also need to get the business for each matched transaction
    #then include nested business
    me = User.find(1)
    @transactions = me.matched_transactions
    render json: @transactions.order(date: :desc), user_id: 1

  end

  def unmatched_transactions

  end

  def businesses
    me = User.find(1)
    @businesses = me.businesses
    render json: @businesses.where.not(id: 1), each_serializer: MatchedBusinessSerializer, user_id: 1
  end

  def show
    @user = User.find(params[:id])
    render json: @user, each_serializer: UserSerializer
  end


end
