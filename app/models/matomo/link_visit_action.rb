# frozen_string_literal: true

module Matomo
  class LinkVisitAction < ApplicationRecord
    self.table_name = 'matomo_log_link_visit_action'
    self.primary_key = 'idlink_va'

    belongs_to :visit, class_name: 'Matomo::Visit', foreign_key: 'idvisit'

    belongs_to :event, class_name: 'Matomo::Action', foreign_key: 'idaction_event_action'
    belongs_to :event_category, class_name: 'Matomo::Action', foreign_key: 'idaction_event_category'
    belongs_to :action_name, class_name: 'Matomo::Action', foreign_key: 'idaction_name'

    scope :all_logs, ->(category) { eager_load(:event_category).where(event_category: category) }

    scope :search_user_name, lambda { |user_name|
      return if user_name.nil? || user_name[1].nil?

      params = {}
      params[ENV['USER_NAME_ATTRIBUTE']] = user_name
      users = User.where(**params)
      where(visit: { user: users })
    }

    scope :serarch_period, lambda { |start_date, end_date|
      where(server_time: start_date&.beginning_of_day..end_date&.end_of_day)
    }

    scope :search_url, lambda { |url|
      return if url.blank?

      joins(:action_name).where('matomo_log_action.name LIKE ?', "%#{url}%")
    }

    scope :search_logs, lambda { |search_params|
      search_user_name(search_params[:user_name])
        .serarch_period(
          search_params[:start_date]&.to_date || Analysis::DEFAULT_START_DATE, search_params[:end_date]&.to_date || Time.zone.today
        )
        .search_url(search_params[:url])
    }

    scope :order_by_server_time, lambda { |order_by, sort|
      if order_by.nil? || order_by != 'started_at'
        order(server_time: :desc)
      else
        order(server_time: sort)
      end
    }

    def self.finish_log(start_log)
      eager_load(:action_name).where('matomo_log_action.name LIKE ?', "%#{start_log.action_name.name.split('::').last}").eager_load(:event).where(event: { name: 'Finish' }).last
    end
  end
end
