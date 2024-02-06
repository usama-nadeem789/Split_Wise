# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations',invitations: 'users/invitations'}
  resources :expenses
  root 'expenses#index'
  get '*path', to: 'errors#route_not_found', via: :all
end
