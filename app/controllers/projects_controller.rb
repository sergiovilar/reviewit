class ProjectsController < ApplicationController
  before_action :authenticate_user!

  def show
    @project = current_user.projects.find(params[:id])
  end

  def new
    @project = Project.new
    @project.users << current_user
  end

  def create
    @project = Project.new(project_params)
    set_project_users
    if @project.save
      flash[:success] = 'The project was successfully created.'

      redirect_to @project
    else
      flash.now[:danger] = 'Please, review the form fields below before try again.'

      render 'new'
    end
  end

  def edit
    project
  end

  def update
    project.update_attributes(project_params)
    set_project_users
    if @project.save
      flash[:success] = 'The project was successfully updated.'

      redirect_to @project
    else
      flash.now[:danger] = 'Please, review the form fields below before try again.'

      render :new
    end
  end

  def destroy
    project.destroy
    flash[:success] = 'The project was successfully destroyed.'

    redirect_to action: :index
  end

  private

  def set_project_users
    names = params[:project][:users].is_a?(Array) ? params[:project][:users] : []
    users = User.where(name: names) << current_user
    users.uniq!
    @project.users = users
  end

  def project_params
    params.require(:project).permit(:name, :repository, :description, :linter,
                                    :summary_addons, :gitlab_ci_project_url, :gitlab_ci_token)
  end
end
