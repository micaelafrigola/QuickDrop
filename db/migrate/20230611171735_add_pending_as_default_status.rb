class AddPendingAsDefaultStatus < ActiveRecord::Migration[7.0]
  def change
    change_column_default :orders, :status, "Pending"
  end
end
