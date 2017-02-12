defmodule UcxChat.Router do
  use UcxChat.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
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

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", UcxChat do
    pipe_through :browser

  end

  scope "/", UcxChat do
    pipe_through :protected

    get "/", PageController, :index
    resources "/channels", ChannelController
  end

  # Other scopes may use custom stacks.
  # scope "/api", UcxChat do
  #   pipe_through :api
  # end
end
