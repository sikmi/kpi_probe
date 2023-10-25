# frozen_string_literal: true

class Processs
  include ActiveModel::Model

  attr_accessor :name, :count, :average_time

  TYPE_EVENT_CATEGORY = 10

  def self.all
    actions = Matomo::Action.where(type: TYPE_EVENT_CATEGORY)
    log_counts = log_counts(actions)
    average_times = average_times(actions)

    actions.map.with_index do |action, index|
      Processs.new(
        name: action.name,
        count: log_counts[index],
        average_time: average_times[index]
      )
    end
  end

  def self.log_counts(actions)
    actions.map do |action|
      Matomo::LinkVisitAction.submit_logs(action).count
    end
  end

  def self.average_times(actions)
    actions.map do |action|
      submit_logs = Matomo::LinkVisitAction.submit_logs(action)
      times = submit_logs.map do |submit_log|
        load_logs = Matomo::LinkVisitAction.load_log(submit_log)
        submit_log.server_time - load_logs.server_time
      end
      times.sum / times.count if times.count.positive?
    end
  end
end
