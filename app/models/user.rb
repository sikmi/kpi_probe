# frozen_string_literal: true

class User < ApplicationRecord
  self.table_name = ENV['USER_TABLE'].blank? ? 'users' : ENV['USER_TABLE']
  self.primary_key = 'id'

  def name
    if ENV['USER_NAME_ATTRIBUTE'].blank? || ENV['USER_NAME_ATTRIBUTE'] == 'name'
      super
    else
      send(ENV['USER_NAME_ATTRIBUTE'])
    end
  end
end
