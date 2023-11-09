# frozen_string_literal: true

module Chartable
  extend ActiveSupport::Concern

  module ClassMethods
    def chart(analysises)
      times = analysises.map(&:time)
      times.delete('--:--:--')
      times = times_to_i(times)
      indicaters = indicaters(times)

      chart = {}
      indicaters.each_with_index do |indicater, i|
        count = times.select { |time| indicater <= time && time < (indicaters[i + 1] || 99_999) }.count
        chart[Time.at(indicater).utc.strftime('%H:%M:%S')] = count
      end
      chart
    end

    def indicaters(times)
      indicaters = []
      10.times do |i|
        indicaters << times.min + interval(times) * i
      end
      indicaters
    end

    def interval(times)
      max_time = times.max
      min_time = times.min
      ((max_time - min_time) / 10.0).to_f
    end

    def times_to_i(times)
      times.map { |time| time.split(':').map(&:to_i) }.map { |time| time[0] * 3600 + time[1] * 60 + time[2] }
    end
  end
end
