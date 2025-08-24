class SyllabusesController < ApplicationController
  def index
    render json: Syllabus.all.includes(:lessons).to_json(include: :lessons)
  end
end
