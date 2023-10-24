# frozen_string_literal: true

module Matomo
  class Visit < ApplicationRecord
    self.table_name = 'matomo_log_visit'
    self.primary_key = 'idvisit'

    belongs_to :user

    has_many :link_visit_actions, class_name: 'Matomo::LinkVisitAction', foreign_key: 'idvisit'
  end
end
