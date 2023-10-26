# frozen_string_literal: true

class AnalysisesController < ApplicationController
  def index
    @analysises = Analysis.all
  end
end
