scope "/", FrontendService do
  pipe_through :browser

  live "/signup", SignupLive
  get "/login", SessionController, :new
  post "/login", SessionController, :create
  delete "/logout", SessionController, :delete
end
