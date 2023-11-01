# frozen_string_literal: true

class Analysis
  include ActiveModel::Model

  attr_accessor :created_at, :process_name, :user_name, :time

  TYPE_EVENT_CATEGORY = 10

  def self.all
    actions = Matomo::Action.where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%')

    submit_logs = Matomo::LinkVisitAction.submit_logs(actions).order(server_time: :desc)
    submit_logs.preload(visit: :user).map do |submit_log|
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
