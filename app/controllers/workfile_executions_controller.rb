class WorkfileExecutionsController < ApplicationController
  before_filter :find_workfile, :find_schema, :verify_workspace, :check_authorization
  require_params :check_id, :only => :create
  require_params :id, :only => :destroy, :field_name => :check_id

  def create
    if params[:download]
      cookies["fileDownload_#{params[:check_id]}".to_sym] = true
      response.headers["Content-Disposition"] = "attachment; filename=#{params[:file_name]}.csv"
      response.headers["Cache-Control"] = 'no-cache'
      response.headers["Transfer-Encoding"] = 'chunked'
      response.headers['Content-Type'] = 'text/csv'
      self.response_body = SqlStreamer.new(@schema, params[:sql], current_user, row_limit).enum
    else
      account = @schema.account_for_user! current_user
      present SqlExecutor.execute_sql(@schema, account, params[:check_id], params[:sql],
                                      :limit => row_limit,
                                      :include_public_schema_in_search_path => true)
    end
  end

  def destroy
    SqlExecutor.cancel_query(@schema, @schema.account_for_user!(current_user), params[:id])
    head :ok
  end

  private

  def find_workfile
    @workfile = Workfile.find(params[:workfile_id] || params[:id])
  end

  def find_schema
    @schema = @workfile.execution_schema
  end

  def verify_workspace
    present_errors({:fields => {:workspace => {:ARCHIVED => {}}}}, :status => :unprocessable_entity) if @workfile.workspace.archived?
  end

  def check_authorization
    authorize! :can_edit_sub_objects, @workfile.workspace
  end

  # TODO: DRY this out of this controller and the previews controller [#39410527]
  def row_limit
    (params[:num_of_rows] || ChorusConfig.instance['default_preview_row_limit'] || 500).to_i
  end
end