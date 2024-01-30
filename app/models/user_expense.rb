# frozen_string_literal: true

class UserExpense < ApplicationRecord
  before_validation :verify_amount_paid
  validates :amount_paid_by_user, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user
  belongs_to :expense

  def verify_amount_paid
    return unless amount_paid_by_user.nil? || amount_paid_by_user.blank?

    self.amount_paid_by_user = 0
  end
end
