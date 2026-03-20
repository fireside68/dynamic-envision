defmodule DynamicEnvisionWeb.ServicesLive.Index do
  use DynamicEnvisionWeb, :live_view

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

    {:ok, assign(socket, page_title: "Services — Dynamic Envision Solutions", current_contractor: current_contractor)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full bg-white">
      <%!-- Navigation --%>
      <.live_component module={DynamicEnvisionWeb.NavigationLive} id="navigation" current_contractor={@current_contractor} />

      <%!-- Page Header --%>
      <div class="bg-gray-900 py-16 lg:py-24">
        <div class="max-w-6xl mx-auto px-6 text-center">
          <h1 class="text-4xl lg:text-5xl font-bold text-white mb-4">Our Services</h1>
          <p class="text-lg text-gray-300 max-w-2xl mx-auto">
            From custom fabrication to full exterior renovations — we do it all.
          </p>
        </div>
      </div>

      <%!-- ============================================================ --%>
      <%!-- WINDOWS & DOORS --%>
      <%!-- ============================================================ --%>
      <div id="windows-doors" class="scroll-mt-16">
        <div class="bg-amber-600 py-5 px-6">
          <div class="max-w-6xl mx-auto flex items-center gap-3">
            <span class="text-2xl">🪟</span>
            <h2 class="text-xl lg:text-2xl font-bold text-white tracking-wide">Windows & Doors</h2>
          </div>
        </div>

        <%!-- Windows — text left, image right --%>
        <.service_section
          id="windows"
          icon="🪟"
          title="Windows"
          description="Energy-efficient windows in every style and material, custom sized and installed to fit your home perfectly."
          items={[
            "Vinyl Windows — low-maintenance, high-efficiency",
            "Wood Windows — classic warmth and character",
            "Composite & Fiberglass — maximum durability",
            "Double and triple-pane options",
            "Custom sizing and UV-protective coatings"
          ]}
          layout={:text_left}
          bg="bg-white"
        />

        <%!-- Doors — image left, text right --%>
        <.service_section
          id="doors"
          icon="🚪"
          title="Doors"
          description="Beautiful, secure entryways and transitions that define your home's character and comfort."
          items={[
            "Entry Doors — steel, fiberglass, and wood",
            "French & Sliding Patio Doors",
            "Storm & Security Doors",
            "Smart lock compatible",
            "Custom glass inserts and weather sealing"
          ]}
          layout={:image_left}
          bg="bg-gray-50"
        />
      </div>

      <%!-- ============================================================ --%>
      <%!-- EXTERIOR --%>
      <%!-- ============================================================ --%>
      <div id="exterior" class="scroll-mt-16">
        <div class="bg-amber-600 py-5 px-6">
          <div class="max-w-6xl mx-auto flex items-center gap-3">
            <span class="text-2xl">🏠</span>
            <h2 class="text-xl lg:text-2xl font-bold text-white tracking-wide">Exterior</h2>
          </div>
        </div>

        <%!-- Siding — text left, image right --%>
        <.service_section
          id="siding"
          icon="🏠"
          title="Siding"
          description="Durable siding installations that protect your home and elevate its curb appeal for years to come."
          items={[
            "Vinyl Siding — low-maintenance and colorfast",
            "Wood Siding — natural, timeless character",
            "Fiber Cement — maximum weather resistance",
            "Trim, fascia, and soffit work",
            "Full tear-off and replacement"
          ]}
          layout={:text_left}
          bg="bg-white"
        />

        <%!-- Floors — image left, text right --%>
        <.service_section
          id="floors"
          icon="🪵"
          title="Floors"
          description="Quality flooring solutions for every room, style, and budget — professionally installed from subfloor up."
          items={[
            "Hardwood — timeless and refinishable",
            "Tile — durable and easy to clean",
            "Laminate — budget-friendly beauty",
            "Vinyl Plank (LVP) — waterproof and versatile",
            "Subfloor prep and installation"
          ]}
          layout={:image_left}
          bg="bg-gray-50"
        />

        <%!-- Decks — text left, image right --%>
        <.service_section
          id="decks"
          icon="🌿"
          title="Decks"
          description="Custom decks designed for your lifestyle and built for years of outdoor enjoyment."
          items={[
            "Wood Decks — classic, highly customizable",
            "Composite Decks — low-maintenance and durable",
            "Deck repairs and refinishing",
            "Railings, stairs, and pergola additions",
            "Custom shapes and multi-level designs"
          ]}
          layout={:text_left}
          bg="bg-white"
        />

        <%!-- Fencing — image left, text right --%>
        <.service_section
          id="fencing"
          icon="🔒"
          title="Fencing"
          description="Privacy, security, and curb appeal — we fence to fit your property and your preferences."
          items={[
            "Wood Fencing — privacy and classic style",
            "Vinyl Fencing — clean look, zero maintenance",
            "Chain Link — secure and economical",
            "Custom gates and hardware",
            "Full post setting and installation"
          ]}
          layout={:image_left}
          bg="bg-gray-50"
        />
      </div>

      <%!-- ============================================================ --%>
      <%!-- CUSTOM FABRICATION --%>
      <%!-- ============================================================ --%>
      <div id="fabrication" class="scroll-mt-16">
        <div class="bg-amber-600 py-5 px-6">
          <div class="max-w-6xl mx-auto flex items-center gap-3">
            <span class="text-2xl">⚙️</span>
            <h2 class="text-xl lg:text-2xl font-bold text-white tracking-wide">Custom Fabrication</h2>
          </div>
        </div>

        <%!-- 3D Printing — text left, image right --%>
        <.service_section
          id="3d-printing"
          icon="🖨️"
          title="3D Printing"
          description="Precision-printed parts, prototypes, and one-of-a-kind custom pieces made to your exact spec."
          items={[
            "Custom replacement parts",
            "Prototypes and design iterations",
            "Decorative and architectural pieces",
            "Multiple materials and finishes",
            "Small batch and single-unit production"
          ]}
          layout={:text_left}
          bg="bg-white"
        />

        <%!-- CNC — image left, text right --%>
        <.service_section
          id="cnc"
          icon="⚙️"
          title="CNC"
          description="Computer-controlled cutting and carving with exacting precision across wood and metal."
          items={[
            "Precision wood cutting and routing",
            "Custom millwork and cabinetry components",
            "Metal fabrication and cutting",
            "Engraving and decorative detail work",
            "CAD/CAM design collaboration"
          ]}
          layout={:image_left}
          bg="bg-gray-50"
        />

        <%!-- Custom Containers — text left, image right --%>
        <.service_section
          id="containers"
          icon="📦"
          title="Custom Chests, Boxes & Containers"
          description="Handcrafted storage built to your exact specifications — functional, beautiful, and built to last."
          items={[
            "Storage chests and hope chests",
            "Tool boxes and job site cases",
            "Display cases and shadow boxes",
            "Custom crates and shipping containers",
            "Decorative keepsake boxes"
          ]}
          layout={:text_left}
          bg="bg-white"
        />
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :items, :list, required: true
  attr :layout, :atom, required: true
  attr :bg, :string, default: "bg-white"

  defp service_section(assigns) do
    ~H"""
    <section id={@id} class={"#{@bg} py-16 lg:py-24 scroll-mt-16"}>
      <div class="max-w-6xl mx-auto px-6">
        <div class={"flex flex-col gap-10 lg:gap-16 lg:items-center #{if @layout == :text_left, do: "lg:flex-row", else: "lg:flex-row-reverse"}"}>

          <%!-- Text Content --%>
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-3 mb-4">
              <span class="text-3xl">{@icon}</span>
              <h3 class="text-2xl lg:text-3xl font-bold text-gray-900">{@title}</h3>
            </div>
            <p class="text-gray-500 text-lg mb-8 leading-relaxed">{@description}</p>
            <div class="space-y-4">
              <%= for item <- @items do %>
                <div class="flex items-start gap-3 text-gray-700">
                  <span class="text-amber-500 mt-0.5 flex-shrink-0 font-bold">✓</span>
                  <span>{item}</span>
                </div>
              <% end %>
            </div>
          </div>

          <%!-- Image Placeholder --%>
          <div class="w-full lg:w-2/5 flex-shrink-0">
            <div class="relative aspect-[4/3] bg-gray-100 rounded-2xl overflow-hidden border border-gray-200 shadow-sm">
              <%!-- Wireframe-style X placeholder --%>
              <svg
                class="absolute inset-0 w-full h-full text-gray-200"
                xmlns="http://www.w3.org/2000/svg"
                preserveAspectRatio="none"
              >
                <line x1="0" y1="0" x2="100%" y2="100%" stroke="currentColor" stroke-width="1" />
                <line x1="100%" y1="0" x2="0" y2="100%" stroke="currentColor" stroke-width="1" />
                <rect x="0" y="0" width="100%" height="100%" fill="none" stroke="currentColor" stroke-width="1" />
              </svg>
              <div class="absolute inset-0 flex flex-col items-center justify-center gap-2">
                <span class="text-5xl opacity-20">{@icon}</span>
                <span class="text-xs text-gray-300 font-medium tracking-widest uppercase">Gallery</span>
              </div>
            </div>
          </div>

        </div>
      </div>
    </section>
    """
  end
end
