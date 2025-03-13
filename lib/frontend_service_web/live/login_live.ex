defmodule FrontendServiceWeb.LoginLive do
  use Phoenix.LiveView
  alias Phoenix.LiveView.Flash
  require Logger
  alias FrontendServiceWeb.GoogleSignInButtonComponent

  @auth_service_url "http://localhost:8000/auth/login"

  def render(assigns) do
    ~H"""
    <div class="flex h-screen">
      <!-- Left Side: Placeholder Image -->
      <div class="hidden lg:flex w-1/2 bg-gray-100 justify-center items-center">
        <img src="/images/placeholder.jpg" alt="Placeholder Image" class="w-3/4">
      </div>

      <!-- Right Side: Login Form -->
      <div class="w-full lg:w-1/2 flex flex-col justify-center items-center p-8">
        <div class="w-full max-w-md">
          <h1 class="text-3xl font-bold text-gray-900 mb-6">Welcome Back!</h1>

          <!-- Flash Messages -->
          <%= if @flash["error"] do %>
            <p class="text-red-600 bg-red-100 p-2 rounded text-center"><%= @flash["error"] %></p>
          <% end %>

          <!-- Google Sign-In Button Component -->
          <.live_component module={GoogleSignInButtonComponent} id="google-sign-in" />

          <div class="flex items-center my-4">
            <div class="flex-1 border-t border-gray-300"></div>
            <span class="px-4 text-gray-500">or</span>
            <div class="flex-1 border-t border-gray-300"></div>
          </div>

          <!-- Login Form -->
          <.form for={%{}} phx-submit="login" class="space-y-4">
            <input type="email" name="email" placeholder="Email" class="w-full px-4 py-3 border rounded-md">
            <input type="password" name="password" placeholder="Password" class="w-full px-4 py-3 border rounded-md">

            <!-- Sign In Button -->
            <button type="submit" class="w-full py-3 text-white bg-blue-900 rounded-md hover:bg-blue-700">
              Sign In
            </button>
          </.form>

          <!-- Don't Have an Account? Sign Up Link -->
          <div class="mt-4 text-center text-gray-600">
            Don’t have an account? 
            <a href="/signup" class="text-blue-600 font-medium hover:underline">Sign Up</a>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # OAuth login navigation
    def handle_params(%{"accessToken" => token}, _uri, socket) do
    {:noreply, socket |> put_flash(:info, "Google Login Successful!") |> push_navigate(to: "/dashboard")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  # Handle login event
  def handle_event("login", %{"email" => email, "password" => password}, socket) do
    case authenticate_user(email, password) do
      {:ok, auth_data} ->
        socket =
          socket
          |> put_flash(:info, "Login successful!")
          |> push_navigate(to: "/dashboard")

        {:noreply, socket}

      {:error, reason} ->
        {:noreply, socket |> put_flash(:error, reason)}
    end
  end

  # Call Auth Microservice
  defp authenticate_user(email, password) do
    body = Jason.encode!(%{"email" => email, "password" => password})
    
    headers = [
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(@auth_service_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %HTTPoison.Response{status_code: 400, body: response_body}} ->
        {:error, Jason.decode!(response_body)["message"]}

      {:ok, %HTTPoison.Response{status_code: 401, body: response_body}} ->
        {:error, Jason.decode!(response_body)["message"]}

      {:error, reason} ->
        Logger.error("Error connecting to auth service: #{inspect(reason)}")
        {:error, "Authentication service unavailable"}
    end
  end
end
