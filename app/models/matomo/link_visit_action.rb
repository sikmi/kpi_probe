# frozen_string_literal: true

module Matomo
  class LinkVisitAction < ApplicationRecord
    self.table_name = 'matomo_log_link_visit_action'
    self.primary_key = 'idlink_va'

    belongs_to :visit, class_name: 'Matomo::Visit', foreign_key: 'idvisit'

    belongs_to :event, class_name: 'Matomo::Action', foreign_key: 'idaction_event_action'
    belongs_to :event_category, class_name: 'Matomo::Action', foreign_key: 'idaction_event_category'
    belongs_to :action_name, class_name: 'Matomo::Action', foreign_key: 'idaction_name'

    scope :finish_logs, ->(category) { eager_load(:event_category).where(event_category: category).eager_load(:event).where(event: { name: 'Submit' }) }

    scope :start_log, ->(finish_log) { eager_load(:action_name).where(action_name: finish_log.action_name).eager_load(:event).where(event: { name: 'Load' }).last }

    scope :search_user_name, lambda { |user_name|
      return if user_name.blank?

      users = User.where("#{ENV['USER_NAME_ATTRIBUTE']} LIKE ?", "%#{user_name}%")
      eager_load(visit: :user).where(visit: { user: users })
    }

    scope :serarch_period, lambda { |start_date, end_date|
      where(server_time: start_date&.beginning_of_day..end_date&.end_of_day)
    }
  end
end
