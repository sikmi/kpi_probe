# frozen_string_literal: true

class AnalysisesController < ApplicationController
  def index
    @search_params = search_params
    @analysises = Analysis.search(search_params)
  end

  def search_params
    params.permit(:user_name, :process_name)
  end
end
