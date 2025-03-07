defmodule FrontendService.UserController do
  use MyAppWeb, :controller
  alias MyApp.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User registered successfully")
        |> redirect(to: "/login")
      
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end