# frozen_string_literal: true

module Averageable
  extend ActiveSupport::Concern

  module ClassMethods
    def average_time(analyses)
      return '--:--' if analyses.blank?

      times = analyses.map(&:time)
      times.delete('--:--:--')
      Time.at(times_to_i(times).sum / times.count).utc.strftime('%H:%M:%S')
    end
  end
end
