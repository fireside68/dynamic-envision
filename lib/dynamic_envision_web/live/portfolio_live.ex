defmodule DynamicEnvisionWeb.PortfolioLive do
  use DynamicEnvisionWeb, :live_component

  alias DynamicEnvision.Photos.PhotoShuffle

  @impl true
  def mount(socket) do
    {:ok, assign(socket, portfolio_items: [])}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> load_portfolio_items()

    {:ok, socket}
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, load_portfolio_items(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section id="portfolio" class="bg-gray-50 py-16 lg:py-24">
      <div class="max-w-6xl mx-auto px-6">
        <%!-- Section Header --%>
        <div class="text-center mb-12">
          <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
            Recent Projects
          </h2>
          <p class="text-lg text-gray-600 max-w-2xl mx-auto">
            See our craftsmanship in action across the Denver metro area
          </p>
        </div>

        <%!-- Portfolio Grid --%>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 lg:gap-8 mb-8">
          <%= for image <- @portfolio_items do %>
            <div class="portfolio-item group relative overflow-hidden rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-300">
              <img
                src={image.src}
                alt={image.title}
                class="w-full h-64 object-cover transition-transform duration-300 group-hover:scale-105"
              />
              <%!-- Overlay with project info --%>
              <div class="portfolio-overlay absolute inset-0 bg-gradient-to-t from-gray-900/90 via-gray-900/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-6">
                <div class="flex items-center gap-2 mb-2">
                  <span class="text-xs bg-amber-500 text-white px-2 py-1 rounded-full font-medium">
                    {image.category}
                  </span>
                  <%= if image.location do %>
                    <span class="text-xs text-gray-300 flex items-center gap-1">
                      <span>📍</span>
                      {image.location}
                    </span>
                  <% end %>
                </div>
                <h3 class="text-white font-bold text-lg">
                  {image.title}
                </h3>
              </div>
            </div>
          <% end %>
        </div>

        <%!-- Refresh Button --%>
        <div class="text-center">
          <button
            type="button"
            phx-click="refresh"
            phx-target={@myself}
            class="inline-flex items-center gap-2 bg-amber-600 hover:bg-amber-700 text-white font-semibold px-6 py-3 rounded-lg transition-colors duration-200 group"
          >
            <span class="transition-transform duration-200 group-hover:rotate-180">🔄</span>
            <span>Show different projects</span>
          </button>
        </div>
      </div>
    </section>
    """
  end

  # Private Functions

  defp load_portfolio_items(socket) do
    case load_all_images() do
      {:ok, all_images} ->
        portfolio_items = PhotoShuffle.shuffle_images(all_images, 6)
        assign(socket, portfolio_items: portfolio_items)

      {:error, _reason} ->
        assign(socket, portfolio_items: [])
    end
  end

  defp load_all_images do
    windows_path = Application.app_dir(:dynamic_envision, "priv/static/design/pictures/windows")
    exterior_path = Application.app_dir(:dynamic_envision, "priv/static/design/pictures/exterior")

    # Custom URL builder for dynamic-envision paths
    # Converts: "/full/path/priv/static/design/pictures/windows/IMG_5366.jpg"
    # To: "/design/pictures/windows/IMG_5366.jpg"
    url_builder = fn path, _base_url ->
      case String.split(path, "priv/static/", parts: 2) do
        [_prefix, relative_path] -> "/" <> relative_path
        _ -> "/" <> Path.basename(path)
      end
    end

    with {:ok, windows} <- PhotoShuffle.process_images(windows_path, "Windows", url_builder: url_builder),
         {:ok, exterior} <- PhotoShuffle.process_images(exterior_path, "Exterior", url_builder: url_builder) do
      {:ok, windows ++ exterior}
    end
  end
end
