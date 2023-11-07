# frozen_string_literal: true

class Processs
  include ActiveModel::Model

  attr_accessor :name, :count, :average_time

  TYPE_EVENT_CATEGORY = 10

  def self.all
    categories = Matomo::Action.where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%')
    log_counts = log_counts(categories)
    average_times = average_times(categories)

    categories.map.with_index do |category, index|
      Processs.new(
        name: category.name,
        count: log_counts[index],
        average_time: Time.at(average_times[index]).utc.strftime('%H:%M:%S')
      )
    end
  end

  def self.log_counts(categories)
    categories.map do |category|
      Matomo::LinkVisitAction.start_logs(category).count
    end
  end

  def self.average_times(categories)
    categories.map do |category|
      start_logs = Matomo::LinkVisitAction.start_logs(category)
      times = start_logs.map do |start_log|
        finish_log = Matomo::LinkVisitAction.finish_log(start_log)
        next if finish_log.nil?

        finish_log.server_time - start_log.server_time
      end
      times.compact.sum / times.compact.count if times.count.positive?
    end
  end
end
