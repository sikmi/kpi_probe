# frozen_string_literal: true

class Analysis
  include ActiveModel::Model

  attr_accessor :created_at, :process_name, :user_name, :time

  TYPE_EVENT_CATEGORY = 10

  def self.search(search_params)
    categories = Matomo::Action.where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%').search_process_name(search_params[:process_name])
    submit_logs = Matomo::LinkVisitAction.submit_logs(categories).order(server_time: :desc).search_user_name(search_params[:user_name])

    build_analysises(submit_logs)
  end

  def self.build_analysises(submit_logs)
    submit_logs.map do |submit_log|
      load_log = Matomo::LinkVisitAction.load_log(submit_log)
      Analysis.new(
        created_at: submit_log.server_time,
        process_name: submit_log.event_category.name,
        user_name: submit_log.visit.user.name,
        time: Time.at(submit_log.server_time - load_log.server_time).utc.strftime('%H:%M:%S')
      )
    end
  end
end
