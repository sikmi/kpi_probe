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

      all_logs = Matomo::LinkVisitAction.all_logs(categories)
                                        .order_by_server_time(search_params[:order_by], search_params[:sort])
                                        .search_logs(search_params)
                                        .eager_load(:action_name).eager_load(:event).eager_load(visit: :user)

      build_analyses(all_logs, search_params)
    end

    private

    def build_analyses(all_logs, search_params)
      grouped_logs = all_logs.group_by { |log| log.action_name.name.split('::').last }
      start_event = Matomo::Action.find_by(name: 'Start')
      finish_event = Matomo::Action.find_by(name: 'Finish')

      analyses = grouped_logs.map do |_key, logs|
        start_log = logs.find { |log| log.event == start_event }
        finish_log = logs.find { |log| log.event == finish_event }

        next if start_log.nil?
        next if finish_log.nil? && search_params[:hide_unfinished] == '1'

        build_one(start_log, finish_log)
      end.compact

      return analyses if search_params[:order_by] != 'time'

      order_by_time(analyses, search_params[:sort])
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

    def order_by_time(analyses, sort)
      if sort == 'asc'
        analyses.sort_by(&:time)
      elsif sort == 'desc'
        analyses.sort_by(&:time).reverse
      end
    end
  end
end
