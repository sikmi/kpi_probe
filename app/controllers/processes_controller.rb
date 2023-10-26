# frozen_string_literal: true

class ProcessesController < ApplicationController
  def index
    @processes = Processs.all
  end
end
