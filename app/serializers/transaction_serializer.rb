class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :date, :description, :amount
  belongs_to :business, serializer: MatchedBusinessSerializer
end
