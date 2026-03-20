defmodule DynamicEnvisionWeb.Sections do
  @moduledoc """
  Static section components for the Dynamic Envision Solutions website.

  These are functional components that render static content for Services,
  About, Reviews, and Footer sections.
  """
  use Phoenix.Component

  @doc """
  Renders a single service category card.
  """
  attr :id, :string, required: true
  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :items, :list, required: true

  def section_card(assigns) do
    ~H"""
    <div id={@id} class="bg-gray-50 rounded-xl p-8">
      <div class="text-4xl mb-4">{@icon}</div>
      <h3 class="text-2xl font-bold text-gray-900 mb-4">{@title}</h3>
      <p class="text-gray-600 mb-6">{@description}</p>
      <div class="space-y-3">
        <%= for item <- @items do %>
          <div class="flex items-center gap-2 text-gray-700">
            <span class="text-amber-600">✓</span>
            <span>{item}</span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders the home page Services teaser — three top-level categories with Learn More links.
  """
  attr :id, :string, default: "services"

  def services(assigns) do
    ~H"""
    <section id={@id} class="bg-white py-16 lg:py-24">
      <div class="max-w-6xl mx-auto px-6">
        <%!-- Section Header --%>
        <div class="text-center mb-12">
          <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
            Our Services
          </h2>
          <p class="text-lg text-gray-600 max-w-2xl mx-auto">
            Premium solutions for homes across the Denver metro area
          </p>
        </div>

        <%!-- Service Categories --%>
        <div class="grid lg:grid-cols-3 gap-8 lg:gap-12">
          <%!-- Windows & Doors --%>
          <div id="windows-doors-teaser" class="bg-gray-50 rounded-xl p-8 flex flex-col">
            <div class="text-4xl mb-4">🪟</div>
            <h3 class="text-2xl font-bold text-gray-900 mb-4">Windows & Doors</h3>
            <p class="text-gray-600 mb-6">
              Expert installation of energy-efficient windows and beautiful, secure entry doors
            </p>
            <div class="space-y-3 mb-8">
              <%= for item <- ["Vinyl, Wood & Fiberglass Windows", "Entry & French Doors", "Sliding & Patio Doors", "Storm & Security Doors"] do %>
                <div class="flex items-center gap-2 text-gray-700">
                  <span class="text-amber-600">✓</span>
                  <span>{item}</span>
                </div>
              <% end %>
            </div>
            <div class="mt-auto">
              <.link navigate="/services#windows-doors" class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-700 font-semibold">
                Learn More <span>→</span>
              </.link>
            </div>
          </div>

          <%!-- Exterior --%>
          <div id="exterior-teaser" class="bg-gray-50 rounded-xl p-8 flex flex-col">
            <div class="text-4xl mb-4">🏠</div>
            <h3 class="text-2xl font-bold text-gray-900 mb-4">Exterior</h3>
            <p class="text-gray-600 mb-6">
              Complete outdoor solutions for lasting curb appeal and outdoor living
            </p>
            <div class="space-y-3 mb-8">
              <%= for service <- ["Siding", "Decks", "Fencing", "Floors"] do %>
                <div class="flex items-center gap-2 text-gray-700">
                  <span class="text-amber-600">✓</span>
                  <span>{service}</span>
                </div>
              <% end %>
            </div>
            <div class="mt-auto">
              <.link navigate="/services#exterior" class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-700 font-semibold">
                Learn More <span>→</span>
              </.link>
            </div>
          </div>

          <%!-- Custom Fabrication --%>
          <div id="fabrication-teaser" class="bg-gray-50 rounded-xl p-8 flex flex-col">
            <div class="text-4xl mb-4">⚙️</div>
            <h3 class="text-2xl font-bold text-gray-900 mb-4">Custom Fabrication</h3>
            <p class="text-gray-600 mb-6">
              Precision 3D printing, CNC work, and handcrafted custom containers
            </p>
            <div class="space-y-3 mb-8">
              <%= for item <- ["3D Printing", "CNC Cutting & Carving", "Custom Containers", "Chests & Display Cases"] do %>
                <div class="flex items-center gap-2 text-gray-700">
                  <span class="text-amber-600">✓</span>
                  <span>{item}</span>
                </div>
              <% end %>
            </div>
            <div class="mt-auto">
              <.link navigate="/services#fabrication" class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-700 font-semibold">
                Learn More <span>→</span>
              </.link>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  @doc """
  Renders the About section with company information.
  """
  attr :id, :string, default: "about"

  def about(assigns) do
    ~H"""
    <section id={@id} class="bg-gray-50 py-16 lg:py-24">
      <div class="max-w-6xl mx-auto px-6">
        <div class="grid lg:grid-cols-2 gap-12 items-center">
          <%!-- Left: Story --%>
          <div>
            <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 mb-6">
              15+ Years of Excellence
            </h2>
            <div class="prose prose-lg text-gray-600">
              <p class="mb-4">
                Since our founding, Dynamic Envision Solutions has been committed to transforming homes
                across the Denver metro area with premium window and door installations.
              </p>
              <p>
                Our team of experienced professionals takes pride in delivering exceptional craftsmanship,
                superior customer service, and solutions that stand the test of time.
              </p>
            </div>
          </div>

          <%!-- Right: Key Points --%>
          <div class="space-y-6">
            <%= for point <- key_differentiators() do %>
              <div class="flex gap-4">
                <div class="shrink-0 w-12 h-12 bg-amber-100 rounded-lg flex items-center justify-center">
                  <span class="text-2xl">{point.icon}</span>
                </div>
                <div>
                  <h3 class="font-bold text-gray-900 mb-1">{point.title}</h3>
                  <p class="text-gray-600 text-sm">{point.description}</p>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Service Area --%>
        <div class="mt-12 p-6 bg-white rounded-xl border border-gray-200">
          <h3 class="font-bold text-gray-900 mb-2 text-center">Service Area</h3>
          <p class="text-gray-600 text-center">
            Serving the entire Denver metro area, from Cheyenne to Colorado Springs and Boulder to Castle Rock.
          </p>
        </div>
      </div>
    </section>
    """
  end

  @doc """
  Renders the Reviews section.
  """
  attr :id, :string, default: "reviews"

  def reviews(assigns) do
    ~H"""
    <section id={@id} class="bg-white py-16 lg:py-24">
      <div class="max-w-6xl mx-auto px-6">
        <div class="text-center mb-12">
          <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
            What Our Customers Say
          </h2>
          <p class="text-lg text-gray-600 max-w-2xl mx-auto">
            Don't just take our word for it
          </p>
        </div>

        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          <%= for review <- sample_reviews() do %>
            <div class="bg-gray-50 rounded-xl p-6">
              <div class="flex gap-1 mb-4">
                <%= for _star <- 1..5 do %>
                  <span class="text-amber-500">⭐</span>
                <% end %>
              </div>
              <p class="text-gray-700 mb-4 italic">
                "{review.text}"
              </p>
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center font-bold text-amber-700">
                  {String.first(review.name)}
                </div>
                <div>
                  <p class="font-semibold text-gray-900">{review.name}</p>
                  <p class="text-sm text-gray-500">{review.location}</p>
                </div>
              </div>
            </div>
          <% end %>
        </div>

        <div class="mt-12 text-center">
          <p class="text-gray-600 mb-4">See more reviews on Google</p>
          <a
            href="https://www.google.com/maps"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex items-center gap-2 text-amber-600 hover:text-amber-700 font-semibold"
          >
            <span>View on Google Maps</span>
            <span>→</span>
          </a>
        </div>
      </div>
    </section>
    """
  end

  @doc """
  Renders the Footer section.
  """
  def footer(assigns) do
    ~H"""
    <footer class="bg-gray-900 text-white py-12">
      <div class="max-w-6xl mx-auto px-6">
        <div class="text-center">
          <img
            src="/design/logos/fulllogo_transparent.png"
            alt="Dynamic Envision Solutions"
            class="h-16 w-auto mx-auto mb-6 opacity-90"
          />
          <p class="text-gray-400 mb-6">
            &copy; {DateTime.utc_now().year} Dynamic Envision Solutions. All rights reserved.
          </p>
          <div class="flex justify-center gap-6 text-sm text-gray-400">
            <a href="/privacy" class="hover:text-white transition">Privacy Policy</a>
            <a href="/terms" class="hover:text-white transition">Terms of Service</a>
          </div>
        </div>
      </div>
    </footer>
    """
  end

  # Private Functions

  defp key_differentiators do
    [
      %{
        icon: "🎯",
        title: "Expert Craftsmanship",
        description: "Every installation meets the highest standards of quality"
      },
      %{
        icon: "💎",
        title: "Premium Materials",
        description: "We work with only the best manufacturers and products"
      },
      %{
        icon: "🤝",
        title: "Customer First",
        description: "Your satisfaction is our top priority from start to finish"
      },
      %{
        icon: "📋",
        title: "Licensed & Insured",
        description: "Fully licensed and insured for your peace of mind"
      },
      %{
        icon: "⚡",
        title: "Energy Efficient",
        description: "Solutions that reduce energy costs and improve comfort"
      },
      %{
        icon: "🏆",
        title: "15+ Years Experience",
        description: "Decades of experience serving the Denver metro area"
      }
    ]
  end

  defp sample_reviews do
    [
      %{
        name: "Sarah M.",
        location: "Denver, CO",
        text:
          "Outstanding service from start to finish. Our new windows look amazing and have already made a noticeable difference in our energy bills."
      },
      %{
        name: "Mike T.",
        location: "Aurora, CO",
        text:
          "Professional, punctual, and meticulous. The team did an excellent job with our patio door replacement. Highly recommend!"
      },
      %{
        name: "Jennifer K.",
        location: "Boulder, CO",
        text:
          "We couldn't be happier with our new front door. The craftsmanship is exceptional and it's completely transformed our home's curb appeal."
      }
    ]
  end
end
