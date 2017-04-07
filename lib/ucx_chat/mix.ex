defmodule UcxChat.Mix do
  alias UcxChat.Repo

  def migrations_path do
    Path.join [Application.app_dir(:ucx_chat) | ~w(priv repo migrations)]
  end

  def create do
    Ecto.Storage.up Repo
  end

  def update do
    Ecto.Migrator.run Repo, migrations_path, :up, all: true
  end

  def drop do
    Ecto.Storage.down Repo
  end
end
