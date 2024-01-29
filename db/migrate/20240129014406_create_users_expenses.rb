# frozen_string_literal: true

class CreateUsersExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :user_expenses do |t|
      t.integer :amount_paid_by_user,  default: 0
      t.references :user, null: false, foreign_key: true
      t.references :expense, null: false, foreign_key: true

      t.timestamps
    end
  end
end
