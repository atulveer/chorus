class WorkfileDraftController < ApplicationController
  before_filter :find_workfile
  before_filter :authorize_sub_objects, :only => [:create, :update, :destroy]
  def create
    #workfile = Workfile.find(params[:workfile_id])
    #Authority.authorize! :update, workspace, current_user, { :or => :can_edit_sub_objects }

    draft = WorkfileDraft.new(params[:workfile_draft])
    draft.workfile_id = params[:workfile_id]
    draft.owner_id = current_user.id
    draft.save!
    present draft, :status => :created
  end

  def show
    #workfile = Workfile.find(params[:workfile_id])
    #authorize! :show, workfile.workspace
    Authority.authorize! :show,
                         @workfile.workspace,
                         current_user,
                         { :or => [ :current_user_is_in_workspace,
                                    :workspace_is_public ] }
    draft = WorkfileDraft.find_by_owner_id_and_workfile_id!(current_user.id, params[:workfile_id])
    present draft
  end

  def update
    #workfile = Workfile.find(params[:workfile_id])
    #authorize! :can_edit_sub_objects, workfile.workspace

    draft = WorkfileDraft.find_by_owner_id_and_workfile_id!(current_user.id, params[:workfile_id])
    draft.update_attributes!(params[:workfile_draft])
    present draft
  end

  def destroy
    #workfile = Workfile.find(params[:workfile_id])
    #authorize! :can_edit_sub_objects, workfile.workspace

    draft = WorkfileDraft.find_by_owner_id_and_workfile_id!(current_user.id, params[:workfile_id])
    draft.destroy
    render :json => {}
  end


  def find_workfile
    @workfile = Workfile.find(params[:workfile_id])
  end

  def authorize_sub_objects
    Authority.authorize! :update, @workfile.workspace, current_user, { :or => :can_edit_sub_objects }
  end

end