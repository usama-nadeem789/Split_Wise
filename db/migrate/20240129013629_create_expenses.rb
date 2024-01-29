# frozen_string_literal: true

class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.string :description
      t.integer :total_amount, default: 0

      t.timestamps
    end
  end
end
