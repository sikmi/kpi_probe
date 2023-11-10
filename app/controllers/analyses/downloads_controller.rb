# frozen_string_literal: true

require 'csv'

module Analyses
  class DownloadsController < ApplicationController
    def new
      analyses = Analysis.search(search_params)
      send_data generate_csv(analyses), filename: "analyses-#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
    end

    private

    def search_params
      params.permit(:url, :start_date, :end_date, :hide_unfinished, user_name: [], process_name: [])
    end

    def generate_csv(analyses)
      CSV.generate do |csv|
        header = %w[開始日時 プロセス名 ユーザー名 URL 実行時間]
        csv << header
        analyses.each do |analysis|
          column = [
            l(analysis.started_at),
            analysis.process_name,
            analysis.user_name,
            analysis.url,
            analysis.time
          ]
          csv << column
        end
      end
    end
  end
end
