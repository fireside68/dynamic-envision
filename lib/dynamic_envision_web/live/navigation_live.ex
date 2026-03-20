defmodule DynamicEnvisionWeb.NavigationLive do
  use DynamicEnvisionWeb, :live_component

  alias DynamicEnvision.Contractors.Contractor

  @impl true
  def mount(socket) do
    {:ok, assign(socket, mobile_menu_open: false, current_contractor: nil)}
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
          <.link navigate={~p"/"} class="flex items-center gap-3">
            <img
              src="/images/des_logo.svg"
              alt="Dynamic Envision Solutions"
              class="h-12 w-auto"
            />
            <span class="text-lg font-bold text-gray-900 hidden sm:block">
              Dynamic Envision Solutions
            </span>
          </.link>

          <%!-- Desktop Navigation --%>
          <div class="hidden md:flex gap-6 lg:gap-8 text-sm font-medium">
            <.link
              navigate={~p"/services"}
              id="nav-services"
              class="text-gray-700 hover:text-amber-700 transition"
            >
              Services
            </.link>
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

          <%!-- Auth Button --%>
          <div class="hidden md:flex items-center gap-3">
            <%= if @current_contractor do %>
              <%= if Contractor.admin?(@current_contractor) do %>
                <a href="/admin" class="text-sm text-amber-700 font-medium hover:underline">Admin</a>
              <% else %>
                <a href="/portal" class="text-sm text-amber-700 font-medium hover:underline">Portal</a>
              <% end %>
              <a
                href="/auth/logout"
                class="text-sm bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium px-3 py-1.5 rounded-lg transition"
              >
                Sign Out
              </a>
            <% else %>
              <a
                href="/auth/google"
                class="text-sm bg-amber-600 hover:bg-amber-700 text-white font-medium px-3 py-1.5 rounded-lg transition"
              >
                Sign In
              </a>
            <% end %>
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
            <.link
              navigate={~p"/services"}
              phx-click="close_mobile_menu"
              phx-target={@myself}
              id="mobile-nav-services"
              class="block py-3 text-gray-700 hover:text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium"
            >
              Services
            </.link>
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
            <div class="border-t border-gray-100 pt-2 mt-2">
              <%= if @current_contractor do %>
                <%= if Contractor.admin?(@current_contractor) do %>
                  <a href="/admin" class="block py-3 text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium">
                    Admin
                  </a>
                <% else %>
                  <a href="/portal" class="block py-3 text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium">
                    Portal
                  </a>
                <% end %>
                <a href="/auth/logout" class="block py-3 text-gray-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium">
                  Sign Out
                </a>
              <% else %>
                <a href="/auth/google" class="block py-3 text-amber-700 hover:bg-gray-50 rounded-lg px-3 transition font-medium">
                  Sign In
                </a>
              <% end %>
            </div>
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
