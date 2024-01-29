# frozen_string_literal: true

class Expense < ApplicationRecord
  validates :description, presence: { allow_blank: false }
  validates :total_amount, presence: true, numericality: { greater_than: 0, only_integer: true }

  has_many :user_expenses, dependent: :destroy
  has_many :users, through: :user_expenses
end
