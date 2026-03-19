defmodule DynamicEnvisionWeb.HomeLive.Index do
  use DynamicEnvisionWeb, :live_view

  import DynamicEnvisionWeb.Sections

  alias DynamicEnvision.Contractors

  @impl true
  def mount(_params, session, socket) do
    current_contractor =
      case session["contractor_id"] do
        nil -> nil
        id ->
          case Contractors.get_contractor(id) do
            {:ok, c} -> c
            _ -> nil
          end
      end

    {:ok, assign(socket, page_title: "Dynamic Envision Solutions", current_contractor: current_contractor)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full bg-white">
      <%!-- Navigation --%>
      <.live_component module={DynamicEnvisionWeb.NavigationLive} id="navigation" current_contractor={@current_contractor} />

      <%!-- Hero Section with Ken Burns Slideshow --%>
      <.live_component module={DynamicEnvisionWeb.HeroLive} id="hero" />

      <%!-- Services Section --%>
      <.services />

      <%!-- Partners Section (Placeholder) --%>
      <section class="bg-white py-12">
        <div class="max-w-6xl mx-auto px-6">
          <h2 class="text-2xl font-bold text-center text-gray-900 mb-8">
            Trusted Partners
          </h2>
          <div class="flex flex-wrap justify-center items-center gap-8 opacity-50">
            <div class="text-gray-400 text-sm">Partner logos coming soon</div>
          </div>
        </div>
      </section>

      <%!-- Portfolio Section --%>
      <.live_component module={DynamicEnvisionWeb.PortfolioLive} id="portfolio" />

      <%!-- About Section --%>
      <.about />

      <%!-- Reviews Section --%>
      <.reviews />

      <%!-- Contact Section --%>
      <.live_component module={DynamicEnvisionWeb.ContactLive} id="contact" />

      <%!-- Footer --%>
      <.footer />
    </div>
    """
  end
end
