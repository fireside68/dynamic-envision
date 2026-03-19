defmodule DynamicEnvisionWeb.Admin.DashboardLive do
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
          |> assign(:page_title, "Admin Dashboard")
          |> assign(:current_contractor, contractor)
          |> assign(:tab, :time)
          |> assign(:note, "")
          |> assign(:now, DateTime.utc_now())
          |> assign(:timezone, timezone)
          |> assign(:show_inactive, false)
          |> assign(:show_upload_warning, true)
          |> load_my_shift()
          |> load_team()
          |> load_pending_photos()
          |> allow_upload(:photo,
            accept: ~w(.jpg .jpeg .png .webp),
            max_entries: 5,
            max_file_size: 10_000_000,
            external: &presign_upload/2
          )

        {:ok, socket}

      {:error, :not_found} ->
        {:ok, socket |> put_flash(:error, "Not found.") |> redirect(to: "/")}
    end
  end

  defp load_my_shift(socket) do
    id = socket.assigns.current_contractor.id

    socket
    |> assign(:current_shift, Shifts.current_shift(id))
    |> assign(:recent_shifts, Shifts.list_shifts(id))
    |> assign(:weekly_hours, Shifts.weekly_hours(id))
  end

  defp load_team(socket) do
    assign(socket, :team_entries, Shifts.list_all_with_current_shift())
  end

  defp load_pending_photos(socket) do
    socket
    |> assign(:pending_photos, Photos.list_pending_photos())
    |> assign(:all_photos, Photos.list_all_photos())
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, :now, DateTime.utc_now())}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, String.to_existing_atom(tab))}
  end

  # ---- My Time ----

  @impl true
  def handle_event("clock_in", _params, socket) do
    case Shifts.clock_in(socket.assigns.current_contractor.id) do
      {:ok, _} -> {:noreply, socket |> load_my_shift() |> put_flash(:info, "Clocked in.")}
      {:error, :already_clocked_in} -> {:noreply, put_flash(socket, :error, "Already clocked in.")}
    end
  end

  @impl true
  def handle_event("clock_out", %{"note" => note}, socket) do
    case Shifts.clock_out(socket.assigns.current_contractor.id, note) do
      {:ok, _} -> {:noreply, socket |> load_my_shift() |> assign(:note, "") |> put_flash(:info, "Clocked out.")}
      {:error, :not_clocked_in} -> {:noreply, put_flash(socket, :error, "Not currently clocked in.")}
    end
  end

  @impl true
  def handle_event("update_note", %{"note" => note}, socket), do: {:noreply, assign(socket, :note, note)}

  # ---- Team ----

  @impl true
  def handle_event("toggle_inactive", _params, socket) do
    {:noreply, update(socket, :show_inactive, &(!&1))}
  end

  @impl true
  def handle_event("set_active", %{"id" => id, "active" => active}, socket) do
    with {:ok, contractor} <- Contractors.get_contractor(String.to_integer(id)),
         {:ok, _} <- Contractors.set_active(contractor, active == "true") do
      label = if active == "true", do: "activated", else: "deactivated"
      {:noreply, socket |> load_team() |> put_flash(:info, "#{contractor.name} #{label}.")}
    else
      _ -> {:noreply, put_flash(socket, :error, "Could not update contractor.")}
    end
  end

  @impl true
  def handle_event("force_clock_out", %{"id" => id}, socket) do
    contractor_id = String.to_integer(id)

    case Shifts.clock_out(contractor_id, "Clocked out by admin") do
      {:ok, _} ->
        {:noreply, socket |> load_team() |> put_flash(:info, "Contractor clocked out.")}

      {:error, :not_clocked_in} ->
        {:noreply, put_flash(socket, :error, "Contractor is not clocked in.")}
    end
  end

  # ---- Photos ----

  @impl true
  def handle_event("dismiss_warning", _params, socket), do: {:noreply, assign(socket, :show_upload_warning, false)}

  @impl true
  def handle_event("validate", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl true
  def handle_event("save_photos", %{"category" => category, "featured" => featured}, socket) do
    featured_bool = featured == "true"

    uploaded =
      consume_uploaded_entries(socket, :photo, fn %{key: key}, entry ->
        url = UploadHelper.public_url(key)

        case Photos.create_photo(%{
               url: url,
               filename: entry.client_name,
               category: category,
               featured: featured_bool,
               position: 0,
               website_status: "published",
               approved: true,
               uploaded_by_id: socket.assigns.current_contractor.id
             }) do
          {:ok, photo} -> {:ok, photo}
          {:error, _} -> {:postpone, :db_error}
        end
      end)

    if Enum.all?(uploaded, &match?({:ok, _}, &1)) do
      {:noreply, socket |> load_pending_photos() |> put_flash(:info, "#{length(uploaded)} photo(s) uploaded.")}
    else
      {:noreply, socket |> load_pending_photos() |> put_flash(:error, "Some photos could not be saved.")}
    end
  end

  def handle_event("save_photos", params, socket) do
    handle_event("save_photos", Map.put_new(params, "featured", "false"), socket)
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.publish_photo(photo) do
      {:ok, _} -> {:noreply, socket |> load_pending_photos() |> put_flash(:info, "Photo published.")}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not publish photo.")}
    end
  end

  @impl true
  def handle_event("reject", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.archive_photo(photo) do
      {:ok, _} -> {:noreply, socket |> load_pending_photos() |> put_flash(:info, "Photo archived.")}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not archive photo.")}
    end
  end

  @impl true
  def handle_event("toggle_featured", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.update_photo(photo, %{featured: !photo.featured}) do
      {:ok, _} -> {:noreply, load_pending_photos(socket)}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not update photo.")}
    end
  end

  @impl true
  def handle_event("delete_photo", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.delete_photo(photo) do
      {:ok, _} -> {:noreply, socket |> load_pending_photos() |> put_flash(:info, "Photo deleted.")}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not delete photo.")}
    end
  end

  defp presign_upload(entry, socket) do
    case UploadHelper.presign_upload(entry) do
      {:ok, %{url: url, key: key}} -> {:ok, %{uploader: "S3", key: key, url: url}, socket}
      {:error, reason} -> {:error, reason}
    end
  end

  defp elapsed_seconds(clocked_in_at, now), do: DateTime.diff(now, clocked_in_at, :second)

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

  defp format_duration(a, b) do
    finish = b || DateTime.utc_now()
    secs = DateTime.diff(finish, a, :second)
    "#{div(secs, 3600)}h #{secs |> rem(3600) |> div(60)}m"
  end

  defp visible_team(entries, show_inactive) do
    if show_inactive, do: entries, else: Enum.filter(entries, & &1.contractor.active)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen" style="background-color: #f8f8f8;">
      <%!-- Header --%>
      <div style="background-color: #002244;" class="px-6 py-4 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <a href="/"><img src="/images/des_logo.svg" alt="DES" class="h-8 w-auto brightness-0 invert" /></a>
          <span class="text-white font-semibold">Admin</span>
        </div>
        <div class="flex items-center gap-4">
          <span class="text-white/70 text-sm"><%= @current_contractor.name %></span>
          <a href="/auth/logout" class="text-sm text-white/70 hover:text-white transition">Sign Out</a>
        </div>
      </div>

      <%!-- Tab Bar --%>
      <div style="background-color: #001a33;" class="px-6 flex gap-1">
        <button phx-click="switch_tab" phx-value-tab="time"
          class={["px-5 py-3 text-sm font-medium transition border-b-2",
            if(@tab == :time, do: "border-orange-500 text-white", else: "border-transparent text-white/60 hover:text-white/90")]}>
          My Time
        </button>
        <button phx-click="switch_tab" phx-value-tab="team"
          class={["px-5 py-3 text-sm font-medium transition border-b-2",
            if(@tab == :team, do: "border-orange-500 text-white", else: "border-transparent text-white/60 hover:text-white/90")]}>
          Team
          <%= if Enum.count(@team_entries, & &1.current_shift) > 0 do %>
            <span class="ml-1.5 text-xs px-1.5 py-0.5 rounded-full font-bold" style="background-color: #FB4F14;">
              <%= Enum.count(@team_entries, & &1.current_shift) %>
            </span>
          <% end %>
        </button>
        <button phx-click="switch_tab" phx-value-tab="photos"
          class={["px-5 py-3 text-sm font-medium transition border-b-2",
            if(@tab == :photos, do: "border-orange-500 text-white", else: "border-transparent text-white/60 hover:text-white/90")]}>
          Photos
          <%= if length(@pending_photos) > 0 do %>
            <span class="ml-1.5 text-xs px-1.5 py-0.5 rounded-full font-bold" style="background-color: #FB4F14;">
              <%= length(@pending_photos) %>
            </span>
          <% end %>
        </button>
      </div>

      <div class="max-w-3xl mx-auto py-8 px-4 space-y-6">

        <%!-- MY TIME TAB --%>
        <%= if @tab == :time do %>

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
                    <textarea name="note" rows="2"
                      class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-orange-400"
                      placeholder="Any notes..." phx-change="update_note"><%= @note %></textarea>
                  </div>
                  <button type="submit" class="w-full text-white font-semibold py-3 rounded-lg" style="background-color: #002244;">
                    Clock Out
                  </button>
                </form>
              <% else %>
                <button phx-click="clock_in" class="w-full text-white font-semibold py-3 rounded-lg" style="background-color: #FB4F14;">
                  Clock In
                </button>
              <% end %>
            </div>
          </div>

          <div class="bg-white rounded-xl shadow-sm p-6">
            <div class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-2">This Week</div>
            <div class="flex items-end gap-2">
              <span class="text-4xl font-bold text-gray-900"><%= @weekly_hours %></span>
              <span class="text-gray-500 mb-1">hours</span>
            </div>
            <div class="text-xs text-gray-400 mt-1">Monday through now</div>
          </div>

          <%= if !Enum.empty?(@recent_shifts) do %>
            <div class="bg-white rounded-xl shadow-sm overflow-hidden">
              <div class="px-6 py-4 border-b border-gray-100">
                <h2 class="font-semibold text-gray-800">Recent Shifts</h2>
              </div>
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
            </div>
          <% end %>

        <% end %>

        <%!-- TEAM TAB --%>
        <%= if @tab == :team do %>
          <div class="bg-white rounded-xl shadow-sm overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h2 class="font-semibold text-gray-800">
                Contractor Roster
                <span class="text-sm font-normal text-gray-400 ml-1">
                  (<%= Enum.count(@team_entries, & &1.contractor.active) %> active)
                </span>
              </h2>
              <button phx-click="toggle_inactive" class="text-sm text-gray-500 hover:text-gray-700 underline">
                <%= if @show_inactive, do: "Hide inactive", else: "Show inactive" %>
              </button>
            </div>

            <%= if Enum.empty?(visible_team(@team_entries, @show_inactive)) do %>
              <div class="text-center py-12 text-gray-400">No contractors.</div>
            <% else %>
              <table class="w-full text-sm">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Clock</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                  <%= for %{contractor: c, current_shift: shift} <- visible_team(@team_entries, @show_inactive) do %>
                    <tr class={if !c.active, do: "opacity-50"}>
                      <td class="px-6 py-4">
                        <div class="font-medium text-gray-900"><%= c.name %></div>
                        <div class="text-xs text-gray-400"><%= c.email %></div>
                      </td>
                      <td class="px-6 py-4">
                        <span class={[
                          "inline-block text-xs px-2 py-0.5 rounded-full font-medium",
                          if(c.active, do: "bg-green-100 text-green-700", else: "bg-gray-100 text-gray-500")
                        ]}>
                          <%= if c.active, do: "Active", else: "Inactive" %>
                        </span>
                      </td>
                      <td class="px-6 py-4">
                        <%= if shift do %>
                          <span class="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full" style="background-color: #FEE2D5; color: #C13A00;">
                            <span class="w-1.5 h-1.5 rounded-full" style="background-color: #FB4F14;"></span>
                            In since <%= format_time(shift.clocked_in_at, @timezone) %>
                          </span>
                        <% else %>
                          <span class="text-xs text-gray-400">Clocked out</span>
                        <% end %>
                      </td>
                      <td class="px-6 py-4">
                        <div class="flex gap-3">
                          <%= if shift do %>
                            <button
                              phx-click="force_clock_out"
                              phx-value-id={c.id}
                              data-confirm={"Force clock out #{c.name}?"}
                              class="text-xs text-orange-600 hover:underline font-medium"
                            >Force Out</button>
                          <% end %>
                          <%= if c.active do %>
                            <button phx-click="set_active" phx-value-id={c.id} phx-value-active="false"
                              data-confirm={"Deactivate #{c.name}?"}
                              class="text-xs text-red-500 hover:underline">Deactivate</button>
                          <% else %>
                            <button phx-click="set_active" phx-value-id={c.id} phx-value-active="true"
                              class="text-xs text-green-600 hover:underline">Activate</button>
                          <% end %>
                        </div>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            <% end %>
          </div>
        <% end %>

        <%!-- PHOTOS TAB --%>
        <%= if @tab == :photos do %>

          <%!-- Pending review --%>
          <%= if length(@pending_photos) > 0 do %>
            <div class="bg-white rounded-xl shadow-sm overflow-hidden border-l-4" style="border-color: #FB4F14;">
              <div class="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
                <span class="w-2.5 h-2.5 rounded-full animate-pulse" style="background-color: #FB4F14;"></span>
                <h2 class="font-semibold text-gray-800">
                  Pending Review <span class="text-sm font-normal text-gray-400">(<%= length(@pending_photos) %>)</span>
                </h2>
              </div>
              <div class="divide-y divide-gray-100">
                <%= for photo <- @pending_photos do %>
                  <div class="flex items-center gap-4 px-6 py-4">
                    <img src={photo.url} alt={photo.filename} class="w-20 h-20 object-cover rounded-lg shrink-0 bg-gray-100" />
                    <div class="flex-1 min-w-0">
                      <p class="text-sm font-medium text-gray-900 truncate"><%= photo.filename %></p>
                      <span class="inline-block text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full mt-1"><%= photo.category %></span>
                      <p class="text-xs text-gray-400 mt-1"><%= Calendar.strftime(photo.inserted_at, "%b %d, %Y") %></p>
                    </div>
                    <div class="flex gap-2 shrink-0">
                      <button phx-click="approve" phx-value-id={photo.id}
                        class="text-xs px-3 py-1.5 rounded-lg border font-medium text-white"
                        style="background-color: #002244; border-color: #002244;">Approve</button>
                      <button phx-click="reject" phx-value-id={photo.id}
                        data-confirm="Reject and delete this photo?"
                        class="text-xs px-3 py-1.5 rounded-lg border border-red-300 text-red-600 hover:bg-red-50 font-medium">Reject</button>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>

          <%!-- Upload --%>
          <div class="bg-white rounded-xl shadow-sm p-6">
            <h2 class="font-semibold text-gray-800 mb-1">Upload Photos</h2>
            <p class="text-sm text-gray-500 mb-4">Admin uploads are approved automatically.</p>

            <%= if @show_upload_warning do %>
              <div class="mb-5 flex gap-3 bg-amber-50 border border-amber-200 rounded-lg p-4">
                <div class="text-amber-500 shrink-0">⚠️</div>
                <div class="flex-1">
                  <p class="text-sm font-semibold text-amber-800">Photos must be edited before uploading</p>
                  <p class="text-sm text-amber-700 mt-0.5">Ensure photos are cropped, color-corrected, and client-ready.</p>
                </div>
                <button phx-click="dismiss_warning" class="text-amber-400 hover:text-amber-600 shrink-0">✕</button>
              </div>
            <% end %>

            <form id="admin-upload-form" phx-submit="save_photos" phx-change="validate">
              <div class="flex flex-wrap gap-6 mb-5">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
                  <select name="category" class="rounded-lg border-gray-300 text-sm">
                    <option value="windows">Windows</option>
                    <option value="exterior">Exterior</option>
                    <option value="doors">Doors</option>
                    <option value="general">General</option>
                  </select>
                </div>
                <div class="flex items-end gap-2">
                  <input type="checkbox" name="featured" value="true" id="admin-featured"
                    class="rounded border-gray-300 text-amber-600 focus:ring-amber-500" />
                  <label for="admin-featured" class="text-sm font-medium text-gray-700">Feature in hero slideshow</label>
                </div>
              </div>

              <div class="border-2 border-dashed border-gray-300 rounded-lg p-10 text-center hover:border-amber-400 transition-colors cursor-pointer"
                phx-drop-target={@uploads.photo.ref}>
                <.live_file_input upload={@uploads.photo} class="hidden" />
                <div class="text-4xl mb-3">📷</div>
                <p class="text-gray-600 text-sm">
                  Drop here or
                  <label for={@uploads.photo.ref} class="text-amber-600 font-semibold cursor-pointer hover:underline">browse</label>
                </p>
                <p class="text-gray-400 text-xs mt-1">JPG, PNG, WEBP · max 10MB · up to 5</p>
              </div>

              <%= if length(@uploads.photo.entries) > 0 do %>
                <div class="mt-5 grid grid-cols-3 sm:grid-cols-5 gap-3">
                  <%= for entry <- @uploads.photo.entries do %>
                    <div class="relative border rounded-lg overflow-hidden bg-gray-50">
                      <.live_img_preview entry={entry} class="w-full h-24 object-cover" />
                      <div class="p-1.5">
                        <p class="text-xs text-gray-600 truncate"><%= entry.client_name %></p>
                        <div class="mt-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                          <div class="h-full bg-amber-500 transition-all" style={"width: #{entry.progress}%"} />
                        </div>
                      </div>
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

              <div class="mt-6">
                <button type="submit"
                  class="bg-amber-600 hover:bg-amber-700 disabled:opacity-40 disabled:cursor-not-allowed text-white font-semibold px-6 py-2.5 rounded-lg transition-colors"
                  disabled={
                    length(@uploads.photo.entries) == 0 or
                      upload_errors(@uploads.photo) != [] or
                      Enum.any?(@uploads.photo.entries, &(upload_errors(@uploads.photo, &1) != []))
                  }>
                  Upload <%= length(@uploads.photo.entries) %> Photo<%= if length(@uploads.photo.entries) != 1, do: "s" %>
                </button>
              </div>
            </form>
          </div>

          <%!-- All photos list --%>
          <%= if length(@all_photos) > 0 do %>
            <div class="bg-white rounded-xl shadow-sm overflow-hidden">
              <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                <h2 class="font-semibold text-gray-800">All Photos <span class="text-sm font-normal text-gray-400">(<%= length(@all_photos) %>)</span></h2>
                <a href="/admin/portfolio" class="text-sm text-amber-600 hover:underline">Full manager →</a>
              </div>
              <div class="divide-y divide-gray-100">
                <%= for photo <- Enum.take(@all_photos, 10) do %>
                  <div class="flex items-center gap-4 px-6 py-3">
                    <img src={photo.url} alt={photo.filename} class="w-14 h-14 object-cover rounded-lg shrink-0 bg-gray-100" />
                    <div class="flex-1 min-w-0">
                      <p class="text-sm font-medium text-gray-900 truncate"><%= photo.filename %></p>
                      <div class="flex gap-1.5 mt-1">
                        <span class="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full"><%= photo.category %></span>
                        <span class={[
                          "text-xs px-2 py-0.5 rounded-full",
                          case photo.website_status do
                            "published" -> "bg-green-100 text-green-700"
                            "archived" -> "bg-gray-100 text-gray-500"
                            "queued" -> "bg-blue-100 text-blue-700"
                            _ -> "bg-orange-100 text-orange-700"
                          end
                        ]}>
                          <%= photo.website_status %>
                        </span>
                        <%= if photo.featured do %>
                          <span class="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">★ featured</span>
                        <% end %>
                      </div>
                    </div>
                    <div class="flex gap-2 shrink-0">
                      <%= if photo.website_status == "published" do %>
                        <button phx-click="toggle_featured" phx-value-id={photo.id}
                          class={["text-xs px-2.5 py-1 rounded-lg border font-medium transition-colors",
                            if(photo.featured,
                              do: "border-amber-300 text-amber-700 bg-amber-50",
                              else: "border-gray-300 text-gray-600 hover:bg-gray-50")]}>
                          <%= if photo.featured, do: "Unfeature", else: "Feature" %>
                        </button>
                      <% else %>
                        <button phx-click="approve" phx-value-id={photo.id}
                          class="text-xs px-2.5 py-1 rounded-lg border border-green-300 text-green-700 hover:bg-green-50 font-medium">Publish</button>
                      <% end %>
                      <button phx-click="delete_photo" phx-value-id={photo.id}
                        data-confirm="Delete this photo?"
                        class="text-xs px-2.5 py-1 rounded-lg border border-red-300 text-red-600 hover:bg-red-50 font-medium">Delete</button>
                    </div>
                  </div>
                <% end %>
                <%= if length(@all_photos) > 10 do %>
                  <div class="px-6 py-3 text-center">
                    <a href="/admin/portfolio" class="text-sm text-amber-600 hover:underline">View all <%= length(@all_photos) %> photos →</a>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>

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
