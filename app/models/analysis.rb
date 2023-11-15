# frozen_string_literal: true

class Analysis
  include ActiveModel::Model
  include Chartable
  include Averageable

  attr_accessor :started_at, :process_name, :user_name, :time, :url

  DEFAULT_START_DATE = Time.zone.today - 30.days

  class << self
    def search(search_params)
      categories = Matomo::Action.categories.search_process_name(search_params[:process_name])
      start_logs = Matomo::LinkVisitAction.start_logs(categories).order_by_server_time(search_params[:order_by], search_params[:sort]).search_logs(search_params)

      build_analyses(start_logs, search_params).compact
    end

    private

    def build_analyses(start_logs, search_params)
      array = start_logs.eager_load(visit: :user).map do |start_log|
        finish_log = Matomo::LinkVisitAction.finish_log(start_log)
        next if finish_log.nil? && search_params[:hide_unfinished] == '1'

        build_one(start_log, finish_log)
      end

      return array if search_params[:order_by] != 'time'

      order_by_time(array, search_params[:sort])
    end

    def build_one(start_log, finish_log)
      Analysis.new(
        started_at: start_log.server_time,
        process_name: start_log.event_category.name,
        user_name: start_log.visit.user.name,
        url: start_log.action_name.name.split('::').first,
        time: finish_log.present? ? Time.at(finish_log.server_time - start_log.server_time).utc.strftime('%H:%M:%S') : '--:--:--'
      )
    end

    def order_by_time(array, sort)
      if sort == 'asc'
        array.sort_by(&:time)
      elsif sort == 'desc'
        array.sort_by(&:time).reverse
      end
    end
  end
end
