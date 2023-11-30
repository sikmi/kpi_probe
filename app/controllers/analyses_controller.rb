# frozen_string_literal: true

class AnalysesController < ApplicationController
  before_action :set_params, only: :show

  def show
    analyses = Analysis.search_analyses(@search_params)
    @analyses = analyses.page(params[:page]).per(100)
    @chart = Analysis.chart(analyses)
    @total_count = analyses.count
    @average_time = Analysis.average_time(analyses)
    @unfinished_count = analyses.select { |analysis| analysis.time == '--:--:--' }.count
    @unfinished_rate = @total_count.zero? ? 0 : (@unfinished_count.to_f / @total_count * 100).round(1)
  end

  private

  def search_params
    params.permit(:url, :start_date, :end_date, :hide_unfinished, :page, :order_by, :sort, user_name: [], process_name: [])
  end

  def set_params
    ignore_invalid_sort
    @default_start_date = Analysis::DEFAULT_START_DATE
  end

  def ignore_invalid_sort
    copied_params = search_params
    @search_params = if search_params[:sort] != 'asc' && search_params[:sort] != 'desc'
                       copied_params.merge(sort: 'desc')
                     else
                       copied_params
                     end
  end
end
