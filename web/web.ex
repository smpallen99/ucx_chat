defmodule UcxChat.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use UcxChat.Web, :controller
      use UcxChat.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def service do
    quote do
      import Ecto.Query
      alias UcxChat.{Repo, RoomChannel, UserChannel, Settings}
      alias UcxChat.ServiceHelpers, as: Helpers
      require UcxChat.SharedView
      use UcxChat.Gettext
      import Phoenix.HTML, only: [safe_to_string: 1]
    end
  end

  def model do
    quote do
      use Ecto.Schema
      use UcxChat.Gettext

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      alias UcxChat.Settings

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end

  def channel_controller do
    quote do
      alias UcxChat.Repo
      import Ecto
      import Ecto.Query
      alias UcxChat.Settings
      use UcxChat.Utils
      use UcxChat.Gettext

    end
  end
  def controller do
    quote do
      use Phoenix.Controller
      use UcxChat.Utils

      alias UcxChat.Repo
      import Ecto
      import Ecto.Query

      import UcxChat.Router.Helpers
      use UcxChat.Gettext
      alias UcxChat.Settings
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"
      require Logger

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      use UcxChat.Utils

      alias UcxChat.Settings
      import Phoenix.HTML.Tag
      import UcxChat.Router.Helpers
      import UcxChat.ErrorHelpers
      use UcxChat.Gettext
      import UcxChat.SharedView
      require UcxChat.SharedView
      alias UcxChat.Permission
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias UcxChat.{Repo, Settings}
      import Ecto
      import Ecto.Query
      use UcxChat.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
