defmodule QuiltWeb.Router do
  use QuiltWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug(
      Guardian.Plug.Pipeline,
      error_handler: QuiltWeb.UserController,
      module: QuiltWeb.Guardian
    )

    plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
    plug(Guardian.Plug.LoadResource, allow_blank: true)
  end

  pipeline :webhook do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QuiltWeb do
    pipe_through :browser

    get "/", UserController, :index
    post "/signin", UserController, :sign_in
    get "/signout", UserController, :sign_out
    post "/users", UserController, :create
    get "/users/verify", UserController, :verify_index
    post "/users/verify", UserController, :verify_user

    get "/journal", JournalController, :index
    post "/journal", JournalController, :create
    put "/journal/:id", JournalController, :update

    get "/admin", AdminController, :index
    get "/admin/journals/:journal_id", AdminController, :journal
  end

  scope "/", QuiltWeb do
    post "/webhook", WebhookController, :run
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuiltWeb do
  #   pipe_through :api
  # end
end
