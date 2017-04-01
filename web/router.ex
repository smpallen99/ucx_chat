defmodule UcxChat.Router do
  use UcxChat.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end
  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UcxChat.Coherence do
    pipe_through :protected
    get "/logout", SessionController, :delete
  end

  scope "/", UcxChat do
    pipe_through :browser
    coherence_routes()
  end

  scope "/", UcxChat do
    pipe_through :protected
    coherence_routes :protected
  end

  # scope "/", UcxChat do
  #   pipe_through :browser

  # end

  scope "/", UcxChat do
    pipe_through :protected

    get "/avatar/:username", AvatarController, :show
    get "/", HomeController, :index
    get "/home", HomeController, :index
    get "/channels/:name", ChannelController, :show
    get "/direct/:name", ChannelController, :direct
    get "/switch_user/:user", PageController, :switch_user
    # resources "/channel", ChannelController
  end

  scope "/", UcxChat do
    pipe_through :api
    post "/channels/upload", ChannelController, :upload
  end

  # Other scopes may use custom stacks.
  # scope "/api", UcxChat do
  #   pipe_through :api
  # end
end
