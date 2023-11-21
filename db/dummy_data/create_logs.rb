# frozen_string_literal: true

class CreateLogs
  TYPE_EVENT_CATEGORY = 10
  TYPE_EVENT_NAME = 12
  START_ACTION_ID = 22
  FINISH_ACTION_ID = 24

  def self.call
    new.execute
  end

  def execute
    registerd_processes = Matomo::Action.where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%')
    registered_visits = Matomo::Visit.all

    registerd_processes.each do |process|
      create_logs(process, registered_visits)
    end
  end

  def create_logs(process, registered_visits)
    start_action = Matomo::Action.find(START_ACTION_ID)
    finish_action = Matomo::Action.find(FINISH_ACTION_ID)
    visit = registered_visits.sample

    start_logs = []
    finish_logs = []

    10000.times do |i|
      puts i
      start_time = Time.zone.now - i.hour
      url = "/hoge/#{rand(1..100)}/edit"  
      hash = SecureRandom.hex(8)
      action_name = "#{url}::#{hash}"
      action_name = Matomo::Action.create(name: action_name, type: TYPE_EVENT_NAME, hash: rand(1..99_999_999))
      start_log = {
        idaction_event_category: process.idaction,
        idaction_event_action: start_action.idaction,
        idaction_name: action_name.idaction,
        idvisit: visit.idvisit,
        server_time: start_time,
        idsite: 1,
        idvisitor: visit.idvisitor
      }
      start_logs << start_log

      finish_time = start_time + rand(1..600)
      finish_log = {
        idaction_event_category: process.idaction,
        idaction_event_action: finish_action.idaction,
        idaction_name: action_name.idaction,
        idvisit: visit.idvisit,
        server_time: finish_time,
        idsite: 1,
        idvisitor: visit.idvisitor
      }
      finish_logs << finish_log
    end

    Matomo::LinkVisitAction.insert_all(start_logs)
    Matomo::LinkVisitAction.insert_all(finish_logs)
  end








  def create_start_log(start_action, process, visit, i)
    start_time = Time.zone.now - i.hour
    url = "/hoge/#{rand(1..100)}/edit"
    hash = SecureRandom.hex(8)
    action_name = "#{url}::#{hash}"
    action_name = Matomo::Action.create(name: action_name, type: TYPE_EVENT_NAME, hash: rand(1..99_999_999))

    Matomo::LinkVisitAction.create(
      event_category: process,
      event: start_action,
      action_name:,
      visit:,
      server_time: start_time,
      idsite: 1,
      idvisitor: visit.idvisitor
    )

    [start_time, action_name]
  end

  def create_finish_log(finish_action, process, visit, start_time, action_name)
    finish_time = start_time + rand(1..600)
    Matomo::LinkVisitAction.create(
      event_category: process,
      event: finish_action,
      action_name:,
      visit:,
      server_time: finish_time,
      idsite: 1,
      idvisitor: visit.idvisitor
    )
  end
end

CreateLogs.call if $PROGRAM_NAME == __FILE__
