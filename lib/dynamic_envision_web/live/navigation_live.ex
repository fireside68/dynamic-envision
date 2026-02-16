defmodule DynamicEnvisionWeb.NavigationLive do
  use DynamicEnvisionWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, mobile_menu_open: false)}
  end

  @impl true
  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, update(socket, :mobile_menu_open, &(!&1))}
  end

  @impl true
  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, mobile_menu_open: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="MobileMenu" id="mobile-menu-hook">
      <nav class="sticky top-0 z-50 bg-white/95 backdrop-blur shadow-sm border-b border-gray-200">
        <div class="max-w-6xl mx-auto px-6 py-4 flex justify-between items-center">
          <div class="flex items-center gap-3">
            <img
              src="/design/logos/fulllogo_transparent.png"
              alt="Dynamic Envision Solutions"
              class="h-10 w-auto"
            />
            <span class="text-lg font-bold text-gray-900 hidden sm:block">
              Dynamic Envision Solutions
            </span>
          </div>

          <%!-- Desktop Navigation --%>
          <div class="hidden md:flex gap-6 lg:gap-8 text-sm font-medium">
            <a
              href="#services"
              phx-hook="SmoothScroll"
              id="nav-services"
              class="text-gray-700 hover:text-amber-700 transition"
            >
              Services
            </a>
            <a
              href="#portfolio"
              phx-hook="SmoothScroll"
              id="nav-portfolio"
              class="text-gray-700 hover:text-amber-700 transition"
            >
              Portfolio
            </a>
            <a
              href="#about"
              phx-hook="SmoothScroll"
              id="nav-about"
              class="text-gray-700 hover:text-amber-700 transition"
            >
              About
            </a>
            <a
              href="#contact"
              phx-hook="SmoothScroll"
              id="nav-contact"
              class="text-gray-700 hover:text-amber-700 transition"
            >
              Contact
            </a>
          </div>

          <%!-- Mobile Menu Button --%>
          <button
            type="button"
            phx-click="toggle_mobile_menu"
            phx-target={@myself}
            class="md:hidden p-2 text-gray-700 hover:text-amber-700 transition"
            aria-label={if @mobile_menu_open, do: "Close menu", else: "Open menu"}
          >
            <%= if @mobile_menu_open do %>
              <span class="w-6 h-6 block">✕</span>
            <% else %>
              <span class="w-6 h-6 block">☰</span>
            <% end %>
          </button>
        </div>

        <%!-- Mobile Menu Dropdown --%>
        <div class={"md:hidden absolute top-full left-0 right-0 bg-white border-b border-gray-200 shadow-lg transition-all duration-300 ease-in-out #{if @mobile_menu_open, do: "opacity-100 visible translate-y-0", else: "opacity-0 invisible -translate-y-2"}"}>
          <div class="px-6 py-4 space-y-1">
            <a
              href="#services"
              phx-hook="SmoothScroll"
              phx-click="close_mobile_menu"
              phx-target={@myself}
              id="mobile-nav-services"
              class="block py-3 text-gray-700 hover:text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium"
            >
              Services
            </a>
            <a
              href="#portfolio"
              phx-hook="SmoothScroll"
              phx-click="close_mobile_menu"
              phx-target={@myself}
              id="mobile-nav-portfolio"
              class="block py-3 text-gray-700 hover:text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium"
            >
              Portfolio
            </a>
            <a
              href="#about"
              phx-hook="SmoothScroll"
              phx-click="close_mobile_menu"
              phx-target={@myself}
              id="mobile-nav-about"
              class="block py-3 text-gray-700 hover:text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium"
            >
              About
            </a>
            <a
              href="#contact"
              phx-hook="SmoothScroll"
              phx-click="close_mobile_menu"
              phx-target={@myself}
              id="mobile-nav-contact"
              class="block py-3 text-gray-700 hover:text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium"
            >
              Contact
            </a>
          </div>
        </div>
      </nav>

      <%!-- Overlay for mobile menu --%>
      <%= if @mobile_menu_open do %>
        <div
          class="fixed inset-0 bg-black/20 z-40 md:hidden"
          phx-click="close_mobile_menu"
          phx-target={@myself}
        >
        </div>
      <% end %>
    </div>
    """
  end
end
