class MatchedBusinessSerializer < ActiveModel::Serializer
  attributes :org_id, :name, :total_dem, :total_rep, :total_dem_pct, :total_rep_pct, :user_total_spending

  def total_dem
    object.total_dem
  end

  def total_rep
    object.total_rep
  end

  def total_dem_pct
    object.total_dem_pct
  end

  def total_rep_pct
    object.total_rep_pct
  end

  def user_total_spending
    object.user_total_spending(@instance_options[:user_id])
  end

end
