defmodule BudgetronWeb.Router do
  use BudgetronWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BudgetronWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BudgetronWeb do
    pipe_through :browser

    get "/", PageController, :home
    
    # Import routes
    get "/imports/new", ImportController, :new
    post "/imports", ImportController, :create
    post "/imports/process", ImportController, :process
    get "/imports/review", ImportController, :review
    
    # LiveView route for tinder mode
    live "/imports/review/live", ImportLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BudgetronWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:budgetron, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BudgetronWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
