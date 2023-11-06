# frozen_string_literal: true

class Analysis
  include ActiveModel::Model

  attr_accessor :started_at, :process_name, :user_name, :time

  DEFAULT_START_DATE = Time.zone.today - 30.days
  TYPE_EVENT_CATEGORY = 10

  def self.search(search_params)
    categories = Matomo::Action.where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%').search_process_name(search_params[:process_name])
    finish_logs = Matomo::LinkVisitAction.finish_logs(categories).order(server_time: :desc).search_user_name(search_params[:user_name]).serarch_period(
      search_params[:start_date]&.to_date || DEFAULT_START_DATE, search_params[:end_date]&.to_date || Time.zone.today
    )

    build_analysises(finish_logs)
  end

  def self.build_analysises(finish_logs)
    finish_logs.map do |finish_log|
      start_log = Matomo::LinkVisitAction.start_log(finish_log)
      Analysis.new(
        started_at: start_log.server_time,
        process_name: finish_log.event_category.name,
        user_name: finish_log.visit.user.name,
        time: Time.at(finish_log.server_time - start_log.server_time).utc.strftime('%H:%M:%S')
      )
    end
  end
end
