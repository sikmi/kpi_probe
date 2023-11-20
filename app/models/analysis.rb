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
                                        .search_logs(search_params)
                                        .preload(:action_name, :event, visit: :user)

      build_analyses(all_logs, search_params)
    end

    private

    def build_analyses(all_logs, search_params)
      grouped_logs = all_logs.group_by { |log| log.action_name.name.split('::').last }
      start_event, finish_event = set_events

      analyses = grouped_logs.map do |_key, logs|
        start_log, finish_log = find_logs(logs, start_event, finish_event)

        next if start_log.nil?
        next if finish_log.nil? && search_params[:hide_unfinished] == '1'

        build_one(start_log, finish_log)
      end.compact

      order(analyses, search_params)
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

    def set_events
      [Matomo::Action.find_by(name: 'Start'), Matomo::Action.find_by(name: 'Finish')]
    end

    def find_logs(logs, start_event, finish_event)
      [logs.find { |log| log.event == start_event }, logs.find { |log| log.event == finish_event }]
    end

    def order(analyses, search_params)
      if search_params[:order_by] == 'time'
        order_by_time(analyses, search_params[:sort])
      else
        order_by_started_at(analyses, search_params[:sort])
      end
    end

    def order_by_time(analyses, sort)
      if sort == 'asc'
        analyses.sort_by(&:time)
      else
        analyses.sort_by(&:time).reverse
      end
    end

    def order_by_started_at(analyses, sort)
      if sort == 'asc'
        analyses.sort_by(&:started_at)
      else
        analyses.sort_by(&:started_at).reverse
      end
    end
  end
end
