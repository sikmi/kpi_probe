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

    start_action = Matomo::Action.find(START_ACTION_ID)
    finish_action = Matomo::Action.find(FINISH_ACTION_ID)

    registerd_processes.each do |process|
      1000.times do |i|
        visit = registered_visits.sample
        start_time, action_name = create_start_log(start_action, process, visit, i)
        create_finish_log(finish_action, process, visit, start_time, action_name)
      end
    end
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
