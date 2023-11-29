# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'analyses#show'

  resource :analyses, only: [:show] do
    resource :downloads, only: [:new], module: :analyses
  end
end
