defmodule FrontendServiceWeb.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div class="h-screen flex justify-center items-center">
      <h1 class="text-3xl font-bold text-gray-900">Welcome to the Dashboard!</h1>
    </div>
    """
  end
end