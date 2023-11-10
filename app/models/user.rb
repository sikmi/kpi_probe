# frozen_string_literal: true

class User < ApplicationRecord
  self.table_name = ENV['USER_TABLE'].blank? ? 'users' : ENV['USER_TABLE']
  self.primary_key = 'id'

  has_many :visits, class_name: 'Matomo::Visit', foreign_key: 'user_id'

  def name
    if ENV['USER_NAME_ATTRIBUTE'].blank? || ENV['USER_NAME_ATTRIBUTE'] == 'name'
      super
    else
      send(ENV['USER_NAME_ATTRIBUTE'])
    end
  end

  def self.with_logs
    categories = Matomo::Action.categories
    start_logs = Matomo::LinkVisitAction.start_logs(categories)
    users = start_logs.eager_load(visit: :user).map do |start_log|
      start_log.visit.user
    end
    users.uniq
  end
end
