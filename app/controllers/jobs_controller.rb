class JobsController < ApplicationController
  before_filter :apply_timezone, only: [:create, :update]

  def index
    authorize! :show, workspace

    jobs = workspace.jobs.order_by(params[:order]).includes(Job.eager_load_associations)

    present paginate(jobs), :presenter_options => {:list_view => true}
  end

  def show
    authorize! :show, workspace

    job = workspace.jobs.find(params[:id])

    present job
  end

  def create
    authorize! :can_edit_sub_objects, workspace

    job = Job.new(params[:job])

    Job.transaction do
      job.owner = current_user
      job.save!

      job.subscribe_recipients(params[:job]) if (params[:job][:success_recipients] || params[:job][:failure_recipients])

      workspace.jobs << job
    end

    present job, :status => :created
  end

  def update
    authorize! :can_edit_sub_objects, workspace

    job = workspace.jobs.find(params[:id])

    if params[:job]['running_as_demanded']
      job.enqueue
    elsif params[:job]['kill']
      job.kill
    else
      Job.transaction do
        job.update_attributes!(params[:job])
        job.subscribe_recipients(params[:job]) if (params[:job][:success_recipients] || params[:job][:failure_recipients])
      end
    end

    present job
  end

  def destroy
    authorize! :can_edit_sub_objects, workspace

    Job.find(params[:id]).destroy

    head :ok
  end

  protected

  def apply_timezone
    time_zone = params[:job][:time_zone]

    if params[:job][:interval_unit] != 'on_demand' && time_zone
      params[:job][:next_run] = ActiveSupport::TimeZone[time_zone].parse(DateTime.parse(params[:job][:next_run]).asctime)
      params[:job][:end_run] = ActiveSupport::TimeZone[time_zone].parse(DateTime.parse(params[:job][:end_run]).asctime) if end_run_exists?
    end
  end

  def end_run_exists?
    params[:job][:end_run] && params[:job][:end_run] != 'false'
  end

  def workspace
    @workspace ||= Workspace.find(params[:workspace_id])
  end
end