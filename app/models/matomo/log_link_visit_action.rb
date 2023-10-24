# frozen_string_literal: true

module Matomo
  class LogLinkVisitAction < ApplicationRecord
    self.table_name = 'matomo_log_link_visit_action'
    self.primary_key = 'idlink_va'

    belongs_to :log_visit, class_name: 'Matomo::LogVisit', foreign_key: 'idvisit'

    belongs_to :log_event, class_name: 'Matomo::LogAction', foreign_key: 'idaction_event_action'
    belongs_to :log_event_category, class_name: 'Matomo::LogAction', foreign_key: 'idaction_event_category'
    belongs_to :log_action_name, class_name: 'Matomo::LogAction', foreign_key: 'idaction_name'

    scope :new_post, -> { eager_load(:log_event_category).where(log_event_category: { name: 'NewPost' }) }
    scope :submit, -> { eager_load(:log_event).where(log_event: { name: 'Submit' }) }

    def self.input_times(target)
      submit_logs = send(target).submit
      submit_logs.preload(log_visit: :user).map do |submit_log|
        load_log = eager_load(:log_action_name).where(log_action_name: { name: submit_log.log_action_name.name })
        {
          input_time: submit_log.server_time - load_log.first.server_time,
          user: submit_log.log_visit.user.twitter_name
        }
      end
    end
  end
end
