class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :date, :description, :amount, :original
  belongs_to :business, serializer: MatchedBusinessSerializer
end
