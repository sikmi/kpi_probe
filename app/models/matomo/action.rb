# frozen_string_literal: true

module Matomo
  class Action < ApplicationRecord
    self.table_name = 'matomo_log_action'
    self.primary_key = 'idaction'
    self.inheritance_column = :_type_disabled

    TYPE_EVENT_CATEGORY = 10

    has_many :link_visit_actions_name, class_name: 'Matomo::LinkVisitAction', foreign_key: 'idaction_name'
    has_many :link_visit_actions_event, class_name: 'Matomo::LinkVisitAction',
                                        foreign_key: 'idaction_event_action'
    has_many :link_visit_actions_category, class_name: 'Matomo::LinkVisitAction',
                                           foreign_key: 'idaction_event_category'

    scope :categories, -> { where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%') }
    scope :search_process_name, lambda { |process_name|
      return if process_name.nil? || process_name[1].nil?

      where(name: process_name)
    }

    def self.instance_method_already_implemented?(method_name)
      return true if method_name == 'hash'

      super(method_name)
    end
  end
end
