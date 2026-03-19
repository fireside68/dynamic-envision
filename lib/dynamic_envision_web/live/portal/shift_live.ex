defmodule DynamicEnvisionWeb.Portal.ShiftLive do
  use DynamicEnvisionWeb, :live_view

  alias DynamicEnvision.{Contractors, Shifts, Photos, UploadHelper}

  @impl true
  def mount(_params, session, socket) do
    case Contractors.get_contractor(session["contractor_id"]) do
      {:ok, contractor} ->
        if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

        timezone = get_connect_params(socket)["timezone"] || "America/Denver"

        socket =
          socket
          |> assign(:current_contractor, contractor)
          |> assign(:tab, :time)
          |> assign(:note, "")
          |> assign(:now, DateTime.utc_now())
          |> assign(:timezone, timezone)
          |> assign(:show_upload_warning, true)
          |> load_shift_data()
          |> allow_upload(:photo,
            accept: ~w(.jpg .jpeg .png .webp),
            max_entries: 5,
            max_file_size: 10_000_000,
            external: &presign_upload/2
          )

        {:ok, socket}

      {:error, :not_found} ->
        {:ok, socket |> put_flash(:error, "Contractor not found.") |> redirect(to: "/")}
    end
  end

  defp load_shift_data(socket) do
    id = socket.assigns.current_contractor.id

    socket
    |> assign(:current_shift, Shifts.current_shift(id))
    |> assign(:recent_shifts, Shifts.list_shifts(id))
    |> assign(:weekly_hours, Shifts.weekly_hours(id))
  end

  @impl true
  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, :now, DateTime.utc_now())}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, String.to_existing_atom(tab))}
  end

  @impl true
  def handle_event("clock_in", _params, socket) do
    case Shifts.clock_in(socket.assigns.current_contractor.id) do
      {:ok, _} ->
        {:noreply, socket |> load_shift_data() |> put_flash(:info, "Clocked in.")}

      {:error, :already_clocked_in} ->
        {:noreply, put_flash(socket, :error, "Already clocked in.")}
    end
  end

  @impl true
  def handle_event("clock_out", %{"note" => note}, socket) do
    case Shifts.clock_out(socket.assigns.current_contractor.id, note) do
      {:ok, _} ->
        {:noreply, socket |> load_shift_data() |> assign(:note, "") |> put_flash(:info, "Clocked out.")}

      {:error, :not_clocked_in} ->
        {:noreply, put_flash(socket, :error, "Not currently clocked in.")}
    end
  end

  @impl true
  def handle_event("update_note", %{"note" => note}, socket), do: {:noreply, assign(socket, :note, note)}

  @impl true
  def handle_event("dismiss_warning", _params, socket), do: {:noreply, assign(socket, :show_upload_warning, false)}

  @impl true
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl true
  def handle_event("save_photos", %{"category" => category} = params, socket) do
    contractor = socket.assigns.current_contractor
    job_ref = Map.get(params, "job_ref", "") |> String.trim()
    job_ref = if job_ref == "", do: nil, else: job_ref

    uploaded =
      consume_uploaded_entries(socket, :photo, fn %{key: key}, entry ->
        url = UploadHelper.public_url(key)

        case Photos.create_photo(%{
               url: url,
               filename: entry.client_name,
               category: category,
               featured: false,
               position: 0,
               approved: false,
               website_status: "pending",
               job_ref: job_ref,
               uploaded_by_id: contractor.id
             }) do
          {:ok, photo} -> {:ok, photo}
          {:error, _} -> {:postpone, :db_error}
        end
      end)

    if Enum.all?(uploaded, &match?({:ok, _}, &1)) do
      {:noreply, put_flash(socket, :info, "#{length(uploaded)} photo(s) submitted for review.")}
    else
      {:noreply, put_flash(socket, :error, "Some photos could not be saved.")}
    end
  end

  def handle_event("save_photos", params, socket) do
    handle_event("save_photos", Map.put_new(params, "category", "general"), socket)
  end

  defp presign_upload(entry, socket) do
    case UploadHelper.presign_upload(entry) do
      {:ok, %{url: url, key: key}} -> {:ok, %{uploader: "S3", key: key, url: url}, socket}
      {:error, reason} -> {:error, reason}
    end
  end

  defp elapsed_seconds(clocked_in_at, now) do
    DateTime.diff(now, clocked_in_at, :second)
  end

  defp format_elapsed(seconds) do
    h = div(seconds, 3600)
    m = seconds |> rem(3600) |> div(60)
    s = rem(seconds, 60)
    :io_lib.format("~2..0B:~2..0B:~2..0B", [h, m, s]) |> to_string()
  end

  defp format_time(nil, _tz), do: "—"
  defp format_time(%DateTime{} = dt, timezone) do
    case DateTime.shift_zone(dt, timezone) do
      {:ok, local} -> Calendar.strftime(local, "%I:%M %p")
      _ -> Calendar.strftime(dt, "%I:%M %p")
    end
  end

  defp format_duration(clocked_in_at, clocked_out_at) do
    finish = clocked_out_at || DateTime.utc_now()
    seconds = DateTime.diff(finish, clocked_in_at, :second)
    "#{div(seconds, 3600)}h #{seconds |> rem(3600) |> div(60)}m"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background-color: #f8f8f8;">
      <%!-- Header --%>
      <div style="background-color: #002244;" class="px-6 py-4 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <a href="/"><img src="/images/des_logo.svg" alt="DES" class="h-8 w-auto brightness-0 invert" /></a>
          <span class="text-white font-semibold">Contractor Portal</span>
        </div>
        <div class="flex items-center gap-4">
          <span class="text-white/70 text-sm"><%= @current_contractor.name %></span>
          <a href="/auth/logout" class="text-sm text-white/70 hover:text-white transition">Sign Out</a>
        </div>
      </div>

      <%!-- Tab Bar --%>
      <div style="background-color: #001a33;" class="px-6 flex gap-1">
        <button
          phx-click="switch_tab" phx-value-tab="time"
          class={["px-5 py-3 text-sm font-medium transition border-b-2",
            if(@tab == :time,
              do: "border-orange-500 text-white",
              else: "border-transparent text-white/60 hover:text-white/90")]}
        >Time</button>
        <button
          phx-click="switch_tab" phx-value-tab="photos"
          class={["px-5 py-3 text-sm font-medium transition border-b-2",
            if(@tab == :photos,
              do: "border-orange-500 text-white",
              else: "border-transparent text-white/60 hover:text-white/90")]}
        >Photos</button>
      </div>

      <div class="max-w-2xl mx-auto py-8 px-4 space-y-6">

        <%!-- TIME TAB --%>
        <%= if @tab == :time do %>

          <%!-- Clock In/Out Card --%>
          <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="px-6 py-5" style={"background-color: #{if @current_shift, do: "#FB4F14", else: "#002244"};"}>
              <div class="flex items-center justify-between">
                <div>
                  <div class="text-white font-bold text-lg">
                    <%= if @current_shift, do: "Clocked In", else: "Clocked Out" %>
                  </div>
                  <%= if @current_shift do %>
                    <div class="text-white/90 font-mono text-3xl font-bold mt-1 tabular-nums">
                      <%= format_elapsed(elapsed_seconds(@current_shift.clocked_in_at, @now)) %>
                    </div>
                    <div class="text-white/70 text-sm mt-0.5">since <%= format_time(@current_shift.clocked_in_at, @timezone) %></div>
                  <% else %>
                    <div class="text-white/70 text-sm mt-0.5">Not currently working</div>
                  <% end %>
                </div>
                <%= if @current_shift do %>
                  <div class="w-3 h-3 rounded-full bg-white/60 animate-pulse"></div>
                <% end %>
              </div>
            </div>

            <div class="p-6">
              <%= if @current_shift do %>
                <form phx-submit="clock_out">
                  <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      End-of-shift note <span class="text-gray-400 font-normal">(optional)</span>
                    </label>
                    <textarea
                      name="note" rows="2"
                      class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-orange-400"
                      placeholder="Any notes..."
                      phx-change="update_note"
                    ><%= @note %></textarea>
                  </div>
                  <button type="submit" class="w-full text-white font-semibold py-3 rounded-lg transition" style="background-color: #002244;">
                    Clock Out
                  </button>
                </form>
              <% else %>
                <button phx-click="clock_in" class="w-full text-white font-semibold py-3 rounded-lg transition" style="background-color: #FB4F14;">
                  Clock In
                </button>
              <% end %>
            </div>
          </div>

          <%!-- Weekly Hours --%>
          <div class="bg-white rounded-xl shadow-sm p-6">
            <div class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">This Week</div>
            <div class="flex items-end gap-2">
              <span class="text-4xl font-bold text-gray-900"><%= @weekly_hours %></span>
              <span class="text-gray-500 mb-1">hours</span>
            </div>
            <div class="text-xs text-gray-400 mt-1">Monday through now</div>
          </div>

          <%!-- Recent Shifts --%>
          <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-100">
              <h2 class="font-semibold text-gray-800">Recent Shifts</h2>
            </div>
            <%= if Enum.empty?(@recent_shifts) do %>
              <p class="px-6 py-4 text-gray-400 text-sm">No shifts recorded yet.</p>
            <% else %>
              <table class="w-full text-sm">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">In</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Out</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Duration</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                  <%= for shift <- @recent_shifts do %>
                    <tr>
                      <td class="px-6 py-3 text-gray-900"><%= Calendar.strftime(shift.clocked_in_at, "%b %d") %></td>
                      <td class="px-6 py-3 text-gray-700"><%= format_time(shift.clocked_in_at, @timezone) %></td>
                      <td class="px-6 py-3 text-gray-700"><%= format_time(shift.clocked_out_at, @timezone) %></td>
                      <td class="px-6 py-3 text-gray-700"><%= format_duration(shift.clocked_in_at, shift.clocked_out_at) %></td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            <% end %>
          </div>

        <% end %>

        <%!-- PHOTOS TAB --%>
        <%= if @tab == :photos do %>
          <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-100">
              <h2 class="font-semibold text-gray-800">Submit Photos</h2>
              <p class="text-sm text-gray-500 mt-0.5">Photos are reviewed by admin before appearing on the site.</p>
            </div>

            <div class="p-6">
              <%= if @show_upload_warning do %>
                <div class="mb-5 flex gap-3 bg-amber-50 border border-amber-200 rounded-lg p-4">
                  <div class="text-amber-500 shrink-0">⚠️</div>
                  <div class="flex-1">
                    <p class="text-sm font-semibold text-amber-800">Photos must be edited before uploading</p>
                    <p class="text-sm text-amber-700 mt-0.5">Ensure photos are cropped, color-corrected, and client-ready before submitting.</p>
                  </div>
                  <button phx-click="dismiss_warning" class="text-amber-400 hover:text-amber-600 shrink-0">✕</button>
                </div>
              <% end %>

              <form id="portal-upload-form" phx-submit="save_photos" phx-change="validate">
                <div class="flex flex-wrap gap-4 mb-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
                    <select name="category" class="rounded-lg border-gray-300 text-sm">
                      <option value="windows">Windows</option>
                      <option value="exterior">Exterior</option>
                      <option value="doors">Doors</option>
                      <option value="general">General</option>
                    </select>
                  </div>
                  <div class="flex-1 min-w-40">
                    <label class="block text-sm font-medium text-gray-700 mb-1">
                      Job reference <span class="text-gray-400 font-normal">(optional)</span>
                    </label>
                    <input type="text" name="job_ref" placeholder="e.g. Smith 123 Main St"
                      class="w-full rounded-lg border-gray-300 text-sm" />
                  </div>
                </div>

                <div
                  class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center hover:border-orange-400 transition-colors cursor-pointer"
                  phx-drop-target={@uploads.photo.ref}
                >
                  <.live_file_input upload={@uploads.photo} capture="environment" class="hidden" />
                  <div class="text-3xl mb-2">📷</div>
                  <p class="text-gray-600 text-sm">
                    Drop here or
                    <label for={@uploads.photo.ref} class="font-semibold cursor-pointer hover:underline" style="color: #FB4F14;">browse</label>
                  </p>
                  <p class="text-gray-400 text-xs mt-1">JPG, PNG, WEBP · max 10MB · up to 5</p>
                </div>

                <%= if length(@uploads.photo.entries) > 0 do %>
                  <div class="mt-4 grid grid-cols-3 sm:grid-cols-5 gap-2">
                    <%= for entry <- @uploads.photo.entries do %>
                      <div class="relative border rounded-lg overflow-hidden bg-gray-50">
                        <.live_img_preview entry={entry} class="w-full h-20 object-cover" />
                        <button type="button" phx-click="cancel_upload" phx-value-ref={entry.ref}
                          class="absolute top-1 right-1 bg-red-500 text-white rounded-full w-5 h-5 text-xs flex items-center justify-center hover:bg-red-600">×</button>
                        <%= for err <- upload_errors(@uploads.photo, entry) do %>
                          <p class="text-xs text-red-500 px-1 pb-1"><%= error_to_string(err) %></p>
                        <% end %>
                      </div>
                    <% end %>
                  </div>
                <% end %>

                <%= for err <- upload_errors(@uploads.photo) do %>
                  <p class="text-sm text-red-500 mt-2"><%= error_to_string(err) %></p>
                <% end %>

                <button
                  type="submit"
                  class="mt-5 w-full text-white font-semibold py-2.5 px-4 rounded-lg transition disabled:opacity-40 disabled:cursor-not-allowed"
                  style="background-color: #002244;"
                  disabled={
                    length(@uploads.photo.entries) == 0 or
                      upload_errors(@uploads.photo) != [] or
                      Enum.any?(@uploads.photo.entries, &(upload_errors(@uploads.photo, &1) != []))
                  }
                >
                  Submit <%= length(@uploads.photo.entries) %> Photo<%= if length(@uploads.photo.entries) != 1, do: "s" %> for Review
                </button>
              </form>
            </div>
          </div>
        <% end %>

      </div>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "File too large (max 10MB)"
  defp error_to_string(:too_many_files), do: "Too many files (max 5)"
  defp error_to_string(:not_accepted), do: "Only JPG, PNG, WEBP accepted"
  defp error_to_string(err), do: "Upload error: #{inspect(err)}"
end
