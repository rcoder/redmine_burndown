class BurndownsController < ApplicationController
  unloadable
  menu_item :burndown

  before_filter :find_version_and_project, :authorize, :only => [:show]

  def show
    if @version
        @chart = BurndownChart.new(@version)
    else
        flash.now[:error] = l(:burndown_text_no_sprint)
    end
  end

private
  def find_version_and_project
    @project = Project.find(params[:project_id])
    @version = params[:id] ? @project.versions.find(params[:id]) : @project.current_version
  end
end
