defmodule DynamicEnvisionWeb.HeroLive do
  use DynamicEnvisionWeb, :live_component

  alias DynamicEnvision.Photos.PhotoShuffle

  @impl true
  def mount(socket) do
    {:ok, assign(socket, current_image_index: 0, hero_images: [])}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> load_hero_images()

    {:ok, socket}
  end

  @impl true
  def handle_event("update_hero_image", %{"index" => index}, socket) do
    {:noreply, assign(socket, current_image_index: index)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="relative bg-gray-900 text-white overflow-hidden">
      <%!-- Ken Burns Slideshow Background --%>
      <div
        class="absolute inset-0"
        phx-hook="KenBurns"
        id="hero-slideshow"
        data-images={Jason.encode!(image_data(@hero_images))}
      >
        <%= if length(@hero_images) > 0 do %>
          <%= for {image, index} <- Enum.with_index(@hero_images) do %>
            <div class={"absolute inset-0 transition-opacity duration-1000 #{if index == @current_image_index, do: "opacity-100", else: "opacity-0"}"}>
              <img
                src={image.src}
                alt=""
                class={"w-full h-full object-cover #{if index == @current_image_index, do: "animate-ken-burns", else: ""}"}
                style={if index != @current_image_index, do: "transform: scale(1);", else: ""}
              />
            </div>
          <% end %>
        <% end %>

        <%!-- Dark overlay for readability --%>
        <div class="absolute inset-0 bg-gray-900/75"></div>
        <%!-- Subtle gradient overlay --%>
        <div class="absolute inset-0 bg-gradient-to-b from-gray-900/50 via-transparent to-gray-900/80">
        </div>
      </div>

      <div class="relative max-w-6xl mx-auto px-6 py-16 lg:py-24">
        <%!-- Top section: Logo + headline --%>
        <div class="text-center mb-12 lg:mb-16">
          <%!-- Logo with backdrop --%>
          <div class="relative inline-block mb-8">
            <%!-- Solid backdrop for contrast --%>
            <div class="absolute inset-0 -m-4 bg-white/90 rounded-2xl shadow-lg"></div>
            <%!-- Soft glow effect --%>
            <div class="absolute inset-0 -m-8 bg-amber-400/20 blur-2xl rounded-full"></div>
            <img
              src="/design/logos/fulllogo_transparent.png"
              alt="Dynamic Envision Solutions"
              class="relative w-48 sm:w-56 md:w-64 lg:w-72 h-auto drop-shadow-lg"
            />
          </div>
          <h1 class="text-3xl sm:text-4xl lg:text-5xl font-bold mb-4 leading-tight drop-shadow-lg">
            What Can We Help You With?
          </h1>
          <p class="text-lg text-gray-300 max-w-2xl mx-auto drop-shadow">
            15 years of premium window and door installation across the Denver metro area.
          </p>
        </div>

        <%!-- Product Category Cards --%>
        <div class="grid md:grid-cols-3 gap-6 lg:gap-8">
          <%= for category <- product_categories() do %>
            <a
              href={"##{category.id}"}
              phx-hook="SmoothScroll"
              id={"hero-link-#{category.id}"}
              class="group bg-white/5 backdrop-blur border border-white/10 rounded-xl p-6 lg:p-8 text-left hover:bg-white/10 hover:border-amber-500/50 transition-all duration-300 hover:-translate-y-1"
            >
              <div class="text-4xl mb-4">{category.icon}</div>
              <h3 class="text-xl lg:text-2xl font-bold mb-2 group-hover:text-amber-400 transition-colors">
                {category.title}
              </h3>
              <p class="text-gray-400 text-sm mb-4">
                {category.description}
              </p>
              <div class="flex flex-wrap gap-2 mb-4">
                <%= for feature <- category.features do %>
                  <span class="text-xs bg-white/10 px-2 py-1 rounded-full text-gray-300">
                    {feature}
                  </span>
                <% end %>
              </div>
              <div class="flex items-center text-amber-400 text-sm font-medium group-hover:gap-2 transition-all">
                <span>Learn more</span>
                <span class="ml-1 group-hover:translate-x-1 transition-transform">→</span>
              </div>
            </a>
          <% end %>
        </div>

        <%!-- Trust indicators --%>
        <div class="mt-12 lg:mt-16 flex flex-wrap justify-center gap-8 lg:gap-12 text-sm text-gray-400">
          <div class="flex items-center gap-2">
            <span class="text-amber-500">✓</span>
            <span>Licensed & Insured</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-amber-500">✓</span>
            <span>Free Estimates</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="text-amber-500">✓</span>
            <span>15+ Years Experience</span>
          </div>
        </div>
      </div>
    </section>
    """
  end

  # Private Functions

  defp load_hero_images(socket) do
    case load_images_from_directories() do
      {:ok, images} ->
        hero_images = PhotoShuffle.shuffle_images(images, 8)
        assign(socket, hero_images: hero_images)

      {:error, _reason} ->
        assign(socket, hero_images: [])
    end
  end

  defp load_images_from_directories do
    windows_path = Application.app_dir(:dynamic_envision, "priv/static/images/windows")
    exterior_path = Application.app_dir(:dynamic_envision, "priv/static/images/exterior")

    # Custom URL builder for dynamic-envision paths
    # Converts: "/full/path/priv/static/design/pictures/windows/IMG_5366.jpg"
    # To: "/design/pictures/windows/IMG_5366.jpg"
    url_builder = fn path, _base_url ->
      case String.split(path, "priv/static/", parts: 2) do
        [_prefix, relative_path] -> "/" <> relative_path
        _ -> "/" <> Path.basename(path)
      end
    end

    with {:ok, windows} <-
           PhotoShuffle.process_images(windows_path, "Windows", url_builder: url_builder),
         {:ok, exterior} <-
           PhotoShuffle.process_images(exterior_path, "Exterior", url_builder: url_builder) do
      {:ok, windows ++ exterior}
    end
  end

  defp image_data(images) do
    Enum.map(images, fn image ->
      %{src: image.src, title: image.title}
    end)
  end

  defp product_categories do
    [
      %{
        id: "windows",
        icon: "🪟",
        title: "Windows",
        description: "Energy-efficient windows that enhance comfort and reduce costs",
        features: ["Vinyl", "Wood", "Composite", "Fiberglass"]
      },
      %{
        id: "doors",
        icon: "🚪",
        title: "Doors",
        description: "Beautiful, secure entryways that make a lasting impression",
        features: ["Entry", "French", "Sliding", "Patio"]
      },
      %{
        id: "exterior",
        icon: "🏠",
        title: "Exterior",
        description: "Complete exterior solutions for lasting curb appeal",
        features: ["Siding", "Trim", "Repairs", "Renovations"]
      }
    ]
  end
end
