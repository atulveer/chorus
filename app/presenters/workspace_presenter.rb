class WorkspacePresenter < Presenter
  delegate :id, :name, :summary, :owner, :archiver, :archived_at, :public, to: :model

  def to_hash
    {
        :id => id,
        :name => h(name),
        :summary => h(summary),
        :owner => present(owner),
        :archiver => present(archiver),
        :archived_at => archived_at,
        :public => public
    }
  end
end
