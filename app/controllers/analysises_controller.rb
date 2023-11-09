# frozen_string_literal: true

class AnalysisesController < ApplicationController
  before_action :set_params, only: :index

  def index
    analysises = Analysis.search(search_params)
    @analysises = Kaminari.paginate_array(analysises).page(params[:page]).per(30)
    @chart = Analysis.chart(analysises)
    @total_count = analysises.count
    @average_time = Analysis.average_time(analysises)
    @unfinished_count = analysises.select { |analysis| analysis.time == '--:--:--' }.count
    @unfinished_rate = @total_count.zero? ? 0 : (@unfinished_count.to_f / @total_count * 100).round(1)
  end

  private

  def search_params
    params.permit(:user_name, :process_name, :url, :start_date, :end_date, :hide_unfinished)
  end

  def set_params
    @search_params = search_params
    @default_start_date = Analysis::DEFAULT_START_DATE
  end
end
