# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'processes#index'

  resource :analyses, only: [:show]
end
