defmodule DynamicEnvisionWeb.ServicesLive.Index do
  use DynamicEnvisionWeb, :live_view

  import DynamicEnvisionWeb.Sections

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Services — Dynamic Envision Solutions")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full bg-white">
      <%!-- Page Header --%>
      <div class="bg-gray-900 py-16 lg:py-24">
        <div class="max-w-6xl mx-auto px-6 text-center">
          <h1 class="text-4xl lg:text-5xl font-bold text-white mb-4">Our Services</h1>
          <p class="text-lg text-gray-300 max-w-2xl mx-auto">
            From custom fabrication to full exterior renovations — we do it all.
          </p>
        </div>
      </div>

      <%!-- Windows --%>
      <section id="windows" class="bg-white py-16 lg:py-20">
        <div class="max-w-6xl mx-auto px-6">
          <div class="flex items-center gap-3 mb-2">
            <span class="text-3xl">🪟</span>
            <h2 class="text-2xl lg:text-3xl font-bold text-gray-900">Windows</h2>
          </div>
          <p class="text-gray-500 mb-10">Energy-efficient windows for every style and budget</p>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <.section_card
              id="vinyl-windows"
              icon="🪟"
              title="Vinyl Windows"
              description="Low-maintenance, high-efficiency vinyl frames built to last"
              items={["Double-pane glass", "Custom sizing", "UV coating", "Multiple styles"]}
            />
            <.section_card
              id="wood-windows"
              icon="🌲"
              title="Wood Windows"
              description="Classic warmth and character with premium hardwood frames"
              items={["Interior/exterior options", "Paint or stain finish", "Custom millwork", "Historic restoration"]}
            />
            <.section_card
              id="composite-windows"
              icon="⚡"
              title="Composite & Fiberglass"
              description="Maximum durability with the look of wood and performance of vinyl"
              items={["Extreme weather rated", "Low expansion/contraction", "Paintable surface", "Long warranties"]}
            />
          </div>
        </div>
      </section>

      <hr class="border-gray-100 max-w-6xl mx-auto" />

      <%!-- Doors --%>
      <section id="doors" class="bg-white py-16 lg:py-20">
        <div class="max-w-6xl mx-auto px-6">
          <div class="flex items-center gap-3 mb-2">
            <span class="text-3xl">🚪</span>
            <h2 class="text-2xl lg:text-3xl font-bold text-gray-900">Doors</h2>
          </div>
          <p class="text-gray-500 mb-10">Beautiful, secure entryways that make a lasting impression</p>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <.section_card
              id="entry-doors"
              icon="🚪"
              title="Entry Doors"
              description="Welcoming, secure front doors that define your home's character"
              items={["Steel, fiberglass & wood", "Smart lock compatible", "Custom glass inserts", "Weather sealing"]}
            />
            <.section_card
              id="french-sliding-doors"
              icon="🏡"
              title="French & Sliding Doors"
              description="Elegant transitions between indoor and outdoor living spaces"
              items={["French door systems", "Sliding patio doors", "Multi-slide options", "Screen door packages"]}
            />
            <.section_card
              id="specialty-doors"
              icon="🔑"
              title="Specialty Doors"
              description="Storm doors, bi-fold, and other door solutions for every need"
              items={["Storm & security doors", "Bi-fold & pocket doors", "Barn door hardware", "ADA compliant options"]}
            />
          </div>
        </div>
      </section>

      <hr class="border-gray-100 max-w-6xl mx-auto" />

      <%!-- Exterior & Custom --%>
      <section id="exterior" class="bg-gray-50 py-16 lg:py-20">
        <div class="max-w-6xl mx-auto px-6">
          <div class="flex items-center gap-3 mb-2">
            <span class="text-3xl">🏠</span>
            <h2 class="text-2xl lg:text-3xl font-bold text-gray-900">Exterior & Custom</h2>
          </div>
          <p class="text-gray-500 mb-10">Outdoor living, siding, custom fabrication, and more</p>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            <.section_card
              id="siding"
              icon="🏠"
              title="Siding"
              description="Durable siding installations that protect and beautify"
              items={["Vinyl siding", "Wood siding", "Fiber cement", "Trim & fascia"]}
            />
            <.section_card
              id="floors"
              icon="🪵"
              title="Floors"
              description="Quality flooring solutions for every room and style"
              items={["Hardwood", "Tile", "Laminate", "Vinyl plank"]}
            />
            <.section_card
              id="decks"
              icon="🌿"
              title="Decks"
              description="Custom decks built for comfort and lasting durability"
              items={["Wood decks", "Composite decks", "Deck repairs", "Railings"]}
            />
            <.section_card
              id="fencing"
              icon="🔒"
              title="Fencing"
              description="Fencing solutions for privacy, security, and curb appeal"
              items={["Wood fencing", "Vinyl fencing", "Chain link", "Gates"]}
            />
            <.section_card
              id="3d-printing"
              icon="🖨️"
              title="3D Printing"
              description="Precision-printed parts, prototypes, and custom pieces"
              items={["Custom parts", "Prototypes", "Decorative pieces", "Replacement components"]}
            />
            <.section_card
              id="cnc"
              icon="⚙️"
              title="CNC"
              description="Computer-controlled cutting and carving for exact results"
              items={["Precision cutting", "Custom woodwork", "Metal fabrication", "Engraving"]}
            />
            <.section_card
              id="containers"
              icon="📦"
              title="Custom Chests, Boxes & Containers"
              description="Handcrafted storage built to your exact specifications"
              items={["Storage chests", "Tool boxes", "Display cases", "Custom crates"]}
            />
          </div>
        </div>
      </section>
    </div>
    """
  end
end
