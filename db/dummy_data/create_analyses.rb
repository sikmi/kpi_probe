# frozen_string_literal: true

class CreateAnalyses
  def self.call
    new.execute
  end

  def execute
    categories = Matomo::Action.categories

    all_logs = Matomo::LinkVisitAction.select(:server_time, :idaction_name, :idaction_event_action, :idaction_event_category, :idvisit).all_logs(categories).preload(:action_name, :event, visit: :user)

    create_analyses(all_logs)
  end

  def create_analyses(all_logs)
    grouped_logs = all_logs.group_by { |log| log.action_name.name.split('::').last }
    start_event, finish_event = set_events

    analyses = []
    grouped_logs.map do |_key, logs|
      start_log, finish_log = find_logs(logs, start_event, finish_event)

      next if start_log.nil?

      analyses << build_one(start_log, finish_log)
    end

    Analysis.insert_all(analyses)
  end

  def build_one(start_log, finish_log)
    {
      start_idlink_va: start_log.idlink_va,
      started_at: start_log.server_time,
      process_name: start_log.event_category.name,
      user_name: start_log.visit.user.name,
      url: start_log.action_name.name.split('::').first,
      time: finish_log.present? ? Time.at(finish_log.server_time - start_log.server_time).utc.strftime('%H:%M:%S') : '--:--:--'
    } 
  end

  def set_events
    [Matomo::Action.find_by(name: 'Start'), Matomo::Action.find_by(name: 'Finish')]
  end

  def find_logs(logs, start_event, finish_event)
    [logs.find { |log| log.event == start_event }, logs.find { |log| log.event == finish_event }]
  end
end

CreateAnalyses.call if $PROGRAM_NAME == __FILE__
