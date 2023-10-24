# frozen_string_literal: true

module Matomo
  class LogVisit < ApplicationRecord
    self.table_name = 'matomo_log_visit'
    self.primary_key = 'idvisit'

    belongs_to :user

    has_many :log_link_visit_actions, class_name: 'Matomo::LogLinkVisitAction', foreign_key: 'idvisit'
  end
end
