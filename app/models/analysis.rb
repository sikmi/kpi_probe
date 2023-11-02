# frozen_string_literal: true

class Analysis
  include ActiveModel::Model

  attr_accessor :created_at, :process_name, :user_name, :time

  TYPE_EVENT_CATEGORY = 10

  def self.search(search_params)
    categories = Matomo::Action.where(type: TYPE_EVENT_CATEGORY).where.not('name LIKE ?', '%/%')
    categories = categories.where('name LIKE ?', "%#{search_params[:process_name]}%") if search_params[:process_name].present?

    submit_logs = Matomo::LinkVisitAction.submit_logs(categories).order(server_time: :desc)
    if search_params[:user_name].present?
      users = User.where("#{ENV['USER_NAME_ATTRIBUTE']} LIKE ?", "%#{search_params[:user_name]}%")
      submit_logs = submit_logs.eager_load(visit: :user).where(visit: { user: users })
    end

    submit_logs.preload(visit: :user).map do |submit_log|
      load_log = Matomo::LinkVisitAction.load_log(submit_log)
      Analysis.new(
        created_at: submit_log.server_time,
        process_name: submit_log.event_category.name,
        user_name: submit_log.visit.user.name,
        time: Time.at(submit_log.server_time - load_log.server_time).utc.strftime('%H:%M:%S')
      )
    end
  end
end
