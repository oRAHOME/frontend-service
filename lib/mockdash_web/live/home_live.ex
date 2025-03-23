defmodule MockdashWeb.HomeLive do
  use MockdashWeb, :live_view
  require Logger
  require HTTPoison.Base

  @ha_url "http://192.168.1.94:8123"
  # make sure to replace with your actual Home Assistant URL and token , dm me for testing token and url
  @ha_token "you_goof_u_need_a_token" # Replace with your actual token

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Fetch devices from Home Assistant API
      case fetch_devices() do
        {:ok, devices} ->
          {:ok, assign(socket, :devices, devices)}
        {:error, reason} ->
          Logger.error("Failed to fetch devices: #{inspect(reason)}")
          {:ok, assign(socket, :devices, [])}
      end
    else
      {:ok, assign(socket, :devices, [])}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <h1 class="text-2xl font-bold mb-4">Living Room</h1>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="bg-white rounded-lg p-4 shadow">
          <h2 class="text-lg font-semibold">Current Consumption</h2>
          <p class="text-3xl font-bold">1.5kWh</p>
        </div>

        <div class="bg-white rounded-lg p-4 shadow">
          <h2 class="text-lg font-semibold">Humidity</h2>
          <p class="text-3xl font-bold">48.2%</p>
        </div>

        <div class="bg-white rounded-lg p-4 shadow">
          <h2 class="text-lg font-semibold">Temperature</h2>
          <p class="text-3xl font-bold">28°C</p>
        </div>
      </div>

      <div class="mt-8 grid grid-cols-1 md:grid-cols-5 gap-4">
        <%= for device <- @devices do %>
          <div class="bg-white rounded-lg p-4 shadow">
            <h2 class="text-lg font-semibold"><%= device["attributes"]["friendly_name"] %></h2>
            <%= if device["entity_id"] =~ "light" do %>
              <div class="flex items-center justify-between">
                <label class="mr-2">State:</label>
                <button
                  class={if device["state"] == "on", do: "px-4 py-2 rounded-full bg-blue-500 text-white", else: "px-4 py-2 rounded-full bg-gray-300 text-gray-700"}
                  phx-click="toggle_light"
                  phx-value-entity_id={device["entity_id"]}>
                  <%= if device["state"] == "on", do: "On", else: "Off" %>
                </button>
              </div>
            <% else %>
              <p>No controls available for this device type.</p>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp fetch_devices() do
    headers = [{"Authorization", "Bearer #{@ha_token}"}, {"Content-Type", "application/json"}]
    url = "#{@ha_url}/api/states"

    allowed_entities = [
      "light.bed",
      "light.bedroom_light",
      "light.desk_lamp",
      "light.tv_tile"
    ]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, headers),
         {:ok, devices} <- Jason.decode(body) do
      filtered_devices = devices
        |> Enum.filter(fn device ->
          device["entity_id"] in allowed_entities
        end)

      {:ok, filtered_devices}
    else
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, {:http_error, status_code, body}}
      {:error, reason} ->
        {:error, {:http_request_error, reason}}
    end
  end

  def handle_event("toggle_light", %{"entity_id" => entity_id}, socket) do
    device = Enum.find(socket.assigns.devices, fn d -> d["entity_id"] == entity_id end)
    new_state = if device["state"] == "on", do: "off", else: "on"

    headers = [{"Authorization", "Bearer #{@ha_token}"}, {"Content-Type", "application/json"}]
    url = "#{@ha_url}/api/services/light/turn_#{new_state}"
    body = Jason.encode!(%{
      entity_id: entity_id
    })

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: status_code}} when status_code in [200, 201] ->
        updated_devices = Enum.map(socket.assigns.devices, fn d ->
          if d["entity_id"] == entity_id do
            Map.put(d, "state", new_state)
          else
            d
          end
        end)
        {:noreply, assign(socket, :devices, updated_devices)}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Failed to toggle light: #{status_code} - #{body}")
        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Failed to toggle light: #{inspect(reason)}")
        {:noreply, socket}
    end
  end
end

defmodule MockdashWeb.LightControl do
  use Phoenix.LiveComponent
  require Logger

  @ha_url "http://homeassistant.local:8123"
  @ha_token "YOUR_LONG_LIVED_ACCESS_TOKEN_HERE" # Replace with your actual token

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between">
      <label class="mr-2">State:</label>
      <button
        class={if @device["state"] == "on", do: "px-4 py-2 rounded-full bg-blue-500 text-white", else: "px-4 py-2 rounded-full bg-gray-300 text-gray-700"}
        phx-click="toggle_light"
        phx-value-entity_id={@device["entity_id"]}>
        <%= if @device["state"] == "on", do: "On", else: "Off" %>
      </button>
    </div>
    """
  end

  def handle_event("toggle_light", %{"entity_id" => entity_id}, socket) do
    new_state = if socket.assigns.device["state"] == "on", do: "off", else: "on"
    toggle_light(entity_id, new_state)
    {:noreply, update(Map.put(socket.assigns, :device, Map.put(socket.assigns.device, "state", new_state)), socket)}
  end

  defp toggle_light(entity_id, state) do
    headers = [{"Authorization", "Bearer #{@ha_token}"}, {"Content-Type", "application/json"}]
    url = "#{@ha_url}/api/services/light/turn_#{state}"
    body = Jason.encode!(%{entity_id: entity_id})

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("Light #{entity_id} turned #{state}")
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Failed to toggle light: #{status_code} - #{body}")
      {:error, reason} ->
        Logger.error("Failed to toggle light: #{inspect(reason)}")
    end
  end
end
