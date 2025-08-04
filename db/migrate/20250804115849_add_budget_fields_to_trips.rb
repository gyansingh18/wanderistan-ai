class AddBudgetFieldsToTrips < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :budget_estimate, :string
    add_column :trips, :budget_breakdown, :json
    add_column :trips, :money_saving_tips, :json
  end
end
