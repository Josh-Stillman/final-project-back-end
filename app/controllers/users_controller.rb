require 'activerecord-import'
require 'csv'


class UsersController < ApplicationController

  def matched_transactions
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
    me.load_new_month ? render json: {success: true} : render json: {success: false}
  end

  def recategorize


    old_biz = Business.where(org_id: params[:old]).first
    transactions = old_biz.transactions.where(user_id: params[:id])

    if params[:new] == 1
      transactions.each do |t|
        t.business_id = 1
        t.save
      end
    else
      #create a new business
      #associate the transactions with that business
      #populate its cycles
      #
    end


    render json: {success: true}
  end

  def businesses
    me = User.find(params[:id])
    @businesses = me.businesses
    render json: @businesses.where.not(id: 1), each_serializer: MatchedBusinessSerializer, user_id: params[:id]
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
  end

  def import_csv
    columns = [:date, :description, :original, :amount, :category, :user_id]
    values = []

    ## commented code limits load range
    # i = 1
    CSV.foreach(params[:file].path, headers: true) do |row|
      # if i == 3
      #   break
      # end
      # i += 1


      unless row[4] == "credit"
        row_date = Date.strptime(row[0], '%m/%d/%y')
        row_array = [row_date, row[1], row[2], row[3].to_f, row[5], params[:id]]
        values << row_array
      end
      x = User.find(params[:id])
      x.newest_transaction_month
    end

    if User.find(params[:id]).transactions == []
      Transaction.import columns, values, :validate => false
    else
      Transaction.import columns, values, :validate => true
    end
    render json: {success: true}
  end

  private

  def user_params
    params.require(:username, :password)
  end


end
