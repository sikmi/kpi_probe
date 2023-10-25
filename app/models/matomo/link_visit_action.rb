# frozen_string_literal: true

module Matomo
  class LinkVisitAction < ApplicationRecord
    self.table_name = 'matomo_log_link_visit_action'
    self.primary_key = 'idlink_va'

    belongs_to :visit, class_name: 'Matomo::Visit', foreign_key: 'idvisit'

    belongs_to :event, class_name: 'Matomo::Action', foreign_key: 'idaction_event_action'
    belongs_to :event_category, class_name: 'Matomo::Action', foreign_key: 'idaction_event_category'
    belongs_to :action_name, class_name: 'Matomo::Action', foreign_key: 'idaction_name'

    scope :new_post, -> { eager_load(:event_category).where(event_category: { name: 'NewPost' }) }
    scope :submit, -> { eager_load(:event).where(event: { name: 'Submit' }) }

    def self.input_times(target)
      submit_logs = send(target).submit
      submit_logs.preload(visit: :user).map do |submit_log|
        load_log = eager_load(:action_name).where(action_name: { name: submit_log.action_name.name })
        {
          input_time: submit_log.server_time - load_log.first.server_time,
          user: submit_log.visit.user.twitter_name
        }
      end
    end
  end
end
