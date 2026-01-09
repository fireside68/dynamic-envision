defmodule DynamicEnvisionWeb.ContactLive do
  use DynamicEnvisionWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       form: to_form(%{}, as: :contact),
       submitted: false
     )}
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset = validate_contact(contact_params)
    {:noreply, assign(socket, form: to_form(changeset, as: :contact))}
  end

  @impl true
  def handle_event("submit", %{"contact" => contact_params}, socket) do
    changeset = validate_contact(contact_params)

    if changeset.valid? do
      # In a real app, you'd send an email here via Swoosh
      # For now, we'll just show a success message
      {:noreply,
       socket
       |> assign(submitted: true)
       |> assign(form: to_form(%{}, as: :contact))
       |> put_flash(:info, "Thank you! We'll be in touch soon.")}
    else
      {:noreply, assign(socket, form: to_form(changeset, as: :contact))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section id="contact" class="bg-white py-16 lg:py-24">
      <div class="max-w-6xl mx-auto px-6">
        <div class="grid lg:grid-cols-2 gap-12">
          <%!-- Left: Contact Info --%>
          <div>
            <h2 class="text-3xl lg:text-4xl font-bold text-gray-900 mb-6">
              Request a Free Estimate
            </h2>
            <p class="text-lg text-gray-600 mb-8">
              Ready to transform your home? Get in touch with us today for a free consultation.
            </p>

            <div class="space-y-6">
              <div class="flex items-start gap-4">
                <div class="flex-shrink-0 w-12 h-12 bg-amber-100 rounded-lg flex items-center justify-center">
                  <span class="text-xl">📞</span>
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 mb-1">Call Us</h3>
                  <p class="text-gray-600">(303) 555-0100</p>
                </div>
              </div>

              <div class="flex items-start gap-4">
                <div class="flex-shrink-0 w-12 h-12 bg-amber-100 rounded-lg flex items-center justify-center">
                  <span class="text-xl">📍</span>
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 mb-1">Service Area</h3>
                  <p class="text-gray-600">Denver Metro Area<br />Cheyenne to Pueblo</p>
                </div>
              </div>

              <div class="flex items-start gap-4">
                <div class="flex-shrink-0 w-12 h-12 bg-amber-100 rounded-lg flex items-center justify-center">
                  <span class="text-xl">✓</span>
                </div>
                <div>
                  <h3 class="font-semibold text-gray-900 mb-1">Free Consultations</h3>
                  <p class="text-gray-600">No obligation estimates</p>
                </div>
              </div>
            </div>
          </div>

          <%!-- Right: Contact Form --%>
          <div class="bg-gray-50 rounded-xl p-8">
            <.simple_form
              for={@form}
              id="contact-form"
              phx-change="validate"
              phx-submit="submit"
              phx-target={@myself}
            >
              <.input field={@form[:name]} type="text" label="Your Name" required />
              <.input field={@form[:email]} type="email" label="Email Address" required />
              <.input field={@form[:phone]} type="tel" label="Phone Number" />
              <.input
                field={@form[:message]}
                type="textarea"
                label="Tell us about your project"
                required
              />

              <:actions>
                <.button type="submit" class="w-full">
                  Send Message
                </.button>
              </:actions>
            </.simple_form>

            <%= if @submitted do %>
              <div class="mt-4 p-4 bg-green-50 border border-green-200 rounded-lg text-green-800">
                <p class="font-semibold">✓ Message sent successfully!</p>
                <p class="text-sm">We'll get back to you within 24 hours.</p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </section>
    """
  end

  # Private Functions

  defp validate_contact(params) do
    types = %{
      name: :string,
      email: :string,
      phone: :string,
      message: :string
    }

    {%{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:name, :email, :message])
    |> Ecto.Changeset.validate_format(:email, ~r/@/)
    |> Ecto.Changeset.validate_length(:name, min: 2, max: 100)
    |> Ecto.Changeset.validate_length(:message, min: 10, max: 1000)
  end
end
