# frozen_string_literal: true

module Matomo
  class LogAction < ApplicationRecord
    self.table_name = 'matomo_log_action'
    self.primary_key = 'idaction'
    self.inheritance_column = :_type_disabled

    has_many :log_link_visit_actions_name, class_name: 'Matomo::LogLinkVisitAction', foreign_key: 'idaction_name'
    has_many :log_link_visit_actions_event, class_name: 'Matomo::LogLinkVisitAction',
                                            foreign_key: 'idaction_event_action'
    has_many :log_link_visit_actions_category, class_name: 'Matomo::LogLinkVisitAction',
                                               foreign_key: 'idaction_event_category'

  end
end
