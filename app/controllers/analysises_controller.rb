# frozen_string_literal: true

class AnalysisesController < ApplicationController
  def index
    @search_params = search_params
    @default_start_date = Analysis::DEFAULT_START_DATE
    @analysises = Kaminari.paginate_array(Analysis.search(search_params)).page(params[:page])
  end

  def search_params
    params.permit(:user_name, :process_name, :url, :start_date, :end_date, :hide_unfinished)
  end
end
