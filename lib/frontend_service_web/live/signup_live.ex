defmodule FrontendServiceWeb.SignupLive do
  use Phoenix.LiveView
  require Logger

  @auth_service_url "http://localhost:8000/auth/register"

  def render(assigns) do
    ~H"""
    <div class="flex h-screen">
      <!-- Left Side: Placeholder Image -->
      <div class="hidden lg:flex w-1/2 bg-gray-100 justify-center items-center">
        <img src="/images/placeholder.jpg" alt="Placeholder Image" class="w-3/4">
      </div>

      <!-- Right Side: Signup Form -->
      <div class="w-full lg:w-1/2 flex flex-col justify-center items-center p-8">
        <div class="w-full max-w-md">
          <h1 class="text-3xl font-bold text-gray-900 mb-6">Create an Account</h1>

          <!-- Flash Messages -->
          <%= if @flash["error"] do %>
            <p class="text-red-600 bg-red-100 p-2 rounded text-center"><%= @flash["error"] %></p>
          <% end %>

          <!-- Google Sign-Up Button -->
          <button class="w-full flex items-center justify-center gap-2 px-4 py-3 text-gray-600 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50">
            <img src="/images/google-icon.png" alt="Google" class="h-5 w-5">
            Sign up with Google
          </button>

          <div class="flex items-center my-4">
            <div class="flex-1 border-t border-gray-300"></div>
            <span class="px-4 text-gray-500">or</span>
            <div class="flex-1 border-t border-gray-300"></div>
          </div>

          <!-- Signup Form -->
          <.form for={%{}} phx-submit="register" class="space-y-4">
            <div class="flex gap-4">
              <input type="text" name="username" placeholder="Username" class="w-full px-4 py-3 border rounded-md">
            </div>
            <input type="email" name="email" placeholder="Email" class="w-full px-4 py-3 border rounded-md">
            <input type="password" name="password" placeholder="Password" class="w-full px-4 py-3 border rounded-md">
            
            <label class="flex items-center text-gray-600">
              <input type="checkbox" class="mr-2">
              I agree to the <a href="#" class="text-blue-500 px-1 underline">Terms & Conditions</a>
            </label>

            <!-- Create Account Button -->
            <button type="submit" class="w-full py-3 text-white bg-blue-600 rounded-md hover:bg-blue-700">
              Create Account
            </button>

            <!-- Already Have an Account? Login Link -->
            <div class="mt-4 text-center text-gray-600">
            Already have an account? 
            <a href="/login" class="text-blue-600 font-medium hover:underline">Login</a>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("register", params, socket) do
    case register_user(params) do
      {:ok, _response} ->
        {:noreply, socket |> put_flash(:info, "Registration successful!") |> push_navigate(to: "/login")}

      {:error, reason} ->
        {:noreply, socket |> put_flash(:error, reason)}
    end
  end

  defp register_user(%{"username" => username, "email" => email, "password" => password}) do
    body = Jason.encode!(%{
      "username" => username,
      "email" => email,
      "password" => password,
      "devices" => [] # Assuming empty for now
    })

    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(@auth_service_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: response_body}} ->
        {:ok, Jason.decode!(response_body)}

      {:ok, %HTTPoison.Response{status_code: 400, body: response_body}} ->
        {:error, Jason.decode!(response_body)["message"]}

      {:error, reason} ->
        Logger.error("Error connecting to auth service: #{inspect(reason)}")
        {:error, "Authentication service unavailable"}
    end
  end
end
