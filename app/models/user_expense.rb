# frozen_string_literal: true

class UserExpense < ApplicationRecord
  validates :amount_paid_by_user, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
  belongs_to :expense
end
