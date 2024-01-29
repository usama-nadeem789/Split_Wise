# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :expenses, only: [:index, :new, :create, :show, :destroy]
  root 'expenses#index'
  get '*path', to: 'errors#route_not_found', via: :all
end
