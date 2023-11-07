# frozen_string_literal: true

class Analysis
  include ActiveModel::Model

  attr_accessor :started_at, :process_name, :user_name, :time, :url

  DEFAULT_START_DATE = Time.zone.today - 30.days
  TYPE_EVENT_CATEGORY = 10

  def self.search(search_params)
    categories = Matomo::Action.where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%').search_process_name(search_params[:process_name])
    start_logs = Matomo::LinkVisitAction.start_logs(categories).order(server_time: :desc).search_logs(search_params)

    build_analysises(start_logs, search_params[:hide_unfinished]).compact
  end

  def self.build_analysises(start_logs, hide_unfinished)
    start_logs.eager_load(visit: :user).map do |start_log|
      finish_log = Matomo::LinkVisitAction.finish_log(start_log)
      next if finish_log.nil? && hide_unfinished == '1'

      build_one(start_log, finish_log)
    end
  end

  def self.build_one(start_log, finish_log)
    Analysis.new(
      started_at: start_log.server_time,
      process_name: start_log.event_category.name,
      user_name: start_log.visit.user.name,
      url: start_log.action_name.name.split('::').first,
      time: finish_log.present? ? Time.at(finish_log.server_time - start_log.server_time).utc.strftime('%H:%M:%S') : '--:--:--'
    )
  end
end
