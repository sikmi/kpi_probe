class GenerateAnalyses
  def self.execute!
    ungenerated_logs =  Matomo::LinkVisitAction.left_outer_joins(:analysis).where(analysis: {id: nil}).where(event: Matomo::Action.find_by(name: 'Start'))

    
    return if ungenerated_logs.blank?
    finish_logs = Matomo::LinkVisitAction.where(event: Matomo::Action.find_by(name: 'Finish')).eager_load(:action_name)

    new_analyses = []
    ungenerated_logs.eager_load(:action_name, :event, :event_category, visit: :user).each do |start_log|
      finish_log = finish_logs.find { |log| log.action_name.name.split('::').last == start_log.action_name.name.split('::').last }


      analysis = {
        start_idlink_va: start_log.idlink_va,
        started_at: start_log.server_time,
        process_name: start_log.event_category.name,
        user_name: start_log.visit.user.name,
        url: start_log.action_name.name.split('::').first,
        time: finish_log.present? ? Time.at(finish_log.server_time - start_log.server_time).utc.strftime('%H:%M:%S') : '--:--:--'
      }
      new_analyses << analysis
    end
    Analysis.insert_all(new_analyses)
  end
end