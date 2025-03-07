defmodule FrontendService.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias FrontendService.Repo
  alias FrontendService.Accounts.User
  alias Comeonin.Bcrypt

  # Register a new user
  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Authenticate user (login)
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user && Bcrypt.checkpw(password, user.password_hash) do
      true -> {:ok, user}
      false -> {:error, "Invalid credentials"}
    end
  end

  # List all users
  def list_users do
    Repo.all(User)
  end

  # Get a single user (raises if not found)
  def get_user!(id), do: Repo.get!(User, id)

  # Create a user
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  # Update an existing user
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  # Delete a user
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  # Get an Ecto.Changeset for tracking user changes
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
