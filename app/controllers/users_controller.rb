class UsersController < ApplicationController

  def matched_transactions
    #filter transactions by user
    #filter transactions by analyzed months -- model method to return this array
    #subsequent model method to spit out matched transactions.

    #also need to get the business for each matched transaction
    #then include nested business
    me = User.find(1)
    @transactions = me.matched_transactions
    render json: @transactions

  end

  def unmatched_transactions

  end


end
