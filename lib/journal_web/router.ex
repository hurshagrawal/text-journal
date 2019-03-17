defmodule JournalWeb.Router do
  use JournalWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JournalWeb do
    pipe_through :browser

    get "/", UserController, :index
    post "/users", UserController, :create
    post "/users/login", UserController, :login
    get "/users/verify", UserController, :verify_index
    post "/users/verify", UserController, :verify_user

    post "/journal", JournalController, :index
    put "/journal", JournalController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", JournalWeb do
  #   pipe_through :api
  # end
end
