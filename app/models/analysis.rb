# frozen_string_literal: true

class Analysis < ApplicationRecord
  include Chartable
  include Averageable
  DEFAULT_START_DATE = Time.zone.today - 30.days

  belongs_to :start_log, class_name: 'Matomo::LinkVisitAction', foreign_key: 'start_idlink_va'

  scope :search_analyses, lambda { |search_params|
    search_user_name(search_params[:user_name])
      .search_process_name(search_params[:process_name])
      .search_url(search_params[:url])
      .search_period(
        search_params[:start_date]&.to_date || Analysis::DEFAULT_START_DATE,
        search_params[:end_date]&.to_date || Time.zone.today
      )
      .hide_unfinished(search_params[:hide_unfinished])
      .order_logs(search_params[:order_by], search_params[:sort])
  }

  scope :search_user_name, lambda { |user_name|
    return if user_name.nil? || user_name[1].nil?

    where(user_name:)
  }

  scope :search_process_name, lambda { |process_name|
    return if process_name.nil? || process_name[1].nil?

    where(process_name:)
  }

  scope :search_url, lambda { |url|
    return if url.blank?

    where('url LIKE ?', "%#{url}%")
  }

  scope :search_period, lambda { |start_date, end_date|
    where(started_at: start_date&.beginning_of_day..end_date&.end_of_day)
  }

  scope :hide_unfinished, lambda { |hide_unfinished|
    return if hide_unfinished.nil? || hide_unfinished == 'false'
    
    where.not(time: '--:--:--')
  }

  scope :order_logs, lambda { |order_by, sort|
    if order_by == 'time'
      order_by_time(sort)
    else
      order_by_started_at(sort)
    end
  }

  scope :order_by_time, lambda { |sort|
    if sort == 'asc'
      order(time: :asc)
    else
      order(time: :desc)
    end
  }

  scope :order_by_started_at, lambda { |sort|
    if sort == 'asc'
      order(started_at: :asc)
    else
      order(started_at: :desc)
    end
  }
end
