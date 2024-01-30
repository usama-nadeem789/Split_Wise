# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show destroy edit update]

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

    if @expense.save

      current_user_expense = @expense.user_expenses.new(user: current_user,
                                                        amount_paid_by_user: params['expense']['amount_paid_by_current_user'])
      unless current_user_expense.save
        @expense.errors.add(:base, 'Error in saving current user expense')
        render :new
        return
      end

      params['users_attributes'].each_value do |user|
        if user['email'].empty?
          @expense.errors.add(:base, 'Email of each user is required')
          render :new
          return
        end

        new_user = User.find_by(email: user['email'])

        new_user ||= User.invite!({ email: user['email'] }, current_user)

        user_expense = @expense.user_expenses.new(user: new_user, amount_paid_by_user: user['amount_paid_by_user'])

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
    return unless @expense.destroy

    redirect_to expenses_path, notice: 'Expense deleted successfully'
  end

  def edit
    @expense_users = @expense.user_expenses
  end

  def update
    if @expense.update(expense_params)
      user_expense = UserExpense.find_by(user: current_user, expense: @expense)

      user_expense.amount_paid_by_user = params['expense']['amount_paid_by_current_user']

      unless user_expense.save
        @expense.errors.add(:base, 'Error in updating current user expense')
        @expense_users = @expense.user_expenses
        render :edit
        return
      end

      params['users_attributes'].each_value do |user|
        paid_by = User.find_by(email: user['email'])
        user_expense = UserExpense.find_by(user: paid_by, expense: @expense)

        unless user_expense
          @expense.errors.add(:base, 'User with this email is not sharing the current expense')
          @expense_users = @expense.user_expenses
          render :edit
          return
        end

        user_expense.amount_paid_by_user = user['amount_paid_by_user']

        next if user_expense.save

        @expense.errors.add(:base, 'Error in updating user expense')
        @expense_users = @expense.user_expenses
        render :edit
        return
      end

      redirect_to expense_path(@expense), notice: 'Expense updated successfully'
    else
      @expense.errors.add(:base, 'Error in updating Expense')
      @expense_users = @expense.user_expenses
      render :edit
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
