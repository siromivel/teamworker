class ProjectsController < ApplicationController
  def index
    teamwork ||= Api_Config::TeamWork.new("X", "X")
    @projects ||= teamwork.projects["projects"]
  end

  def create
    teamwork ||= Api_Config::TeamWork.new("X", "X")

    name = params["name"]
    duration = params["duration"]
    clone = params[:clone]

    new = teamwork.create_project(name, duration, clone)
    redirect_to "/projects"
  end
end