# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :destroy]

  def index
    @recent_expenses = current_user.expenses.order(created_at: :desc).limit(5)
    @top_amount_expenses = Expense.joins(:user_expenses).where(user_expenses: { user_id: current_user.id }).order(amount_paid_by_user: :desc).limit(5)
  end

  def new
    @user = current_user
    @expense = Expense.new
  end

  def show
    @expense_users = @expense.user_expenses
  end

  def create
    @user = current_user
    @expense = Expense.new(expense_params)
    amount_paid_by_current_user = params['expense']['amount_paid_by_current_user']

    amount_paid_by_current_user = 0 if amount_paid_by_current_user.blank?

    current_user_expense = @expense.user_expenses.new(user: current_user,
                                                      amount_paid_by_user: amount_paid_by_current_user)

    if @expense.save && current_user_expense.save
      params['users_attributes'].each_value do |user|
        if user['email'].empty?
          @expense.errors.add(:base, 'Email of each user is required')
          render :new
          return
        end

        new_user = User.find_by(email: user['email'])

        new_user ||= User.invite!({ email: user['email'] }, current_user)

        amount_paid_by_user = user['amount_paid_by_user']

        amount_paid_by_user = 0 if amount_paid_by_user.blank?

        user_expense = @expense.user_expenses.new(user: new_user, amount_paid_by_user:)

        @expense.errors.add(:base, 'Error creating Expense Users') unless user_expense.save
      end

      if @expense.errors.empty?
        redirect_to expenses_path, notice: 'Expense generated successfully'
      else
        render :new, alert: 'Error in linking users to the expense'
      end

    else
      @expense.errors.add(:base, 'Error in creating a new Expense')
      render :new
    end
  end

  def destroy
    if @expense.destroy
      redirect_to expenses_path, notice: "Expense deleted successfully"
    end
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to expenses_path, alert: 'Record not found'
  end

  def expense_params
    params.require(:expense).permit(:description, :total_amount)
  end
end
