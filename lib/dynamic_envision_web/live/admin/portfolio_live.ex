defmodule DynamicEnvisionWeb.Admin.PortfolioLive do
  use DynamicEnvisionWeb, :live_view

  alias DynamicEnvision.Photos
  alias DynamicEnvision.UploadHelper

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Admin - Portfolio Management")
      |> assign(:show_upload_warning, true)
      |> load_photos()
      |> allow_upload(:photo,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 5,
        max_file_size: 10_000_000,
        external: &presign_upload/2
      )

    {:ok, socket}
  end

  defp load_photos(socket) do
    socket
    |> assign(:pending_photos, Photos.list_pending_photos())
    |> assign(:photos, Photos.list_all_photos())
  end

  @impl true
  def handle_event("dismiss_warning", _params, socket) do
    {:noreply, assign(socket, :show_upload_warning, false)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"category" => category, "featured" => featured}, socket) do
    featured_bool = featured == "true"

    uploaded_photos =
      consume_uploaded_entries(socket, :photo, fn %{key: key}, entry ->
        url = UploadHelper.public_url(key)

        case Photos.create_photo(%{
               url: url,
               filename: entry.client_name,
               category: category,
               featured: featured_bool,
               position: 0,
               approved: true
             }) do
          {:ok, photo} -> {:ok, photo}
          {:error, _changeset} -> {:postpone, :db_error}
        end
      end)

    errors = Enum.filter(uploaded_photos, &match?({:error, _}, &1))

    if errors == [] do
      {:noreply,
       socket
       |> put_flash(:info, "#{length(uploaded_photos)} photo(s) uploaded and approved.")
       |> load_photos()}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Some photos could not be saved to the database.")
       |> load_photos()}
    end
  end

  def handle_event("save", params, socket) do
    handle_event("save", Map.put_new(params, "featured", "false"), socket)
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.approve_photo(photo) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Photo approved and now visible on site.")
         |> load_photos()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not approve photo.")}
    end
  end

  @impl true
  def handle_event("reject", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.delete_photo(photo) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Photo rejected and removed.")
         |> load_photos()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not remove photo.")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.delete_photo(photo) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Photo deleted.")
         |> load_photos()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete photo.")}
    end
  end

  @impl true
  def handle_event("toggle_featured", %{"id" => id}, socket) do
    photo = Photos.get_photo!(id)

    case Photos.update_photo(photo, %{featured: !photo.featured}) do
      {:ok, _} ->
        {:noreply, load_photos(socket)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update photo.")}
    end
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  defp presign_upload(entry, socket) do
    case UploadHelper.presign_upload(entry) do
      {:ok, %{url: url, key: key}} ->
        {:ok, %{uploader: "S3", key: key, url: url}, socket}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">
      <%!-- Header --%>
      <div style="background-color: #002244;" class="px-6 py-4 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <a href="/"><img src="/images/des_logo.svg" alt="DES" class="h-8 w-auto brightness-0 invert" /></a>
          <span class="text-white font-semibold">Photo Management</span>
        </div>
        <div class="flex items-center gap-3">
          <a href="/admin" class="text-sm text-white/80 hover:text-white transition">← Dashboard</a>
          <a href="/" class="text-sm text-white/80 hover:text-white transition">Site</a>
          <a href="/auth/logout" class="text-sm text-white/70 hover:text-white transition">Sign Out</a>
        </div>
      </div>

      <div class="max-w-5xl mx-auto px-6 py-8 space-y-8">

        <%!-- Pending Review Section --%>
        <%= if length(@pending_photos) > 0 do %>
          <div class="bg-white rounded-xl shadow-sm overflow-hidden border-l-4" style="border-color: #FB4F14;">
            <div class="px-6 py-4 border-b border-gray-100 flex items-center gap-3">
              <span class="w-2.5 h-2.5 rounded-full animate-pulse" style="background-color: #FB4F14;"></span>
              <h2 class="font-semibold text-gray-800">
                Pending Review
                <span class="text-sm font-normal text-gray-400 ml-1">(<%= length(@pending_photos) %>)</span>
              </h2>
            </div>
            <div class="divide-y divide-gray-100">
              <%= for photo <- @pending_photos do %>
                <div class="flex items-center gap-4 px-6 py-4">
                  <img
                    src={photo.url}
                    alt={photo.filename}
                    class="w-20 h-20 object-cover rounded-lg shrink-0 bg-gray-100"
                  />
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate"><%= photo.filename %></p>
                    <span class="inline-block text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full mt-1">
                      <%= photo.category %>
                    </span>
                    <p class="text-xs text-gray-400 mt-1">
                      Submitted <%= Calendar.strftime(photo.inserted_at, "%b %d, %Y") %>
                    </p>
                  </div>
                  <div class="flex items-center gap-2 shrink-0">
                    <button
                      type="button"
                      phx-click="approve"
                      phx-value-id={photo.id}
                      class="text-xs px-3 py-1.5 rounded-lg border font-medium transition-colors text-white"
                      style="background-color: #002244; border-color: #002244;"
                    >
                      Approve
                    </button>
                    <button
                      type="button"
                      phx-click="reject"
                      phx-value-id={photo.id}
                      data-confirm="Reject and delete this photo?"
                      class="text-xs px-3 py-1.5 rounded-lg border border-red-300 text-red-600 hover:bg-red-50 font-medium transition-colors"
                    >
                      Reject
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <%!-- Upload Form --%>
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h2 class="text-lg font-semibold text-gray-800 mb-1">Upload New Photos</h2>
          <p class="text-sm text-gray-500 mb-5">Photos uploaded here are approved automatically.</p>

          <%!-- Edit reminder warning --%>
          <%= if @show_upload_warning do %>
            <div class="mb-5 flex gap-3 bg-amber-50 border border-amber-200 rounded-lg p-4">
              <div class="text-amber-500 text-lg shrink-0">⚠️</div>
              <div class="flex-1">
                <p class="text-sm font-semibold text-amber-800">Photos must be edited before uploading</p>
                <p class="text-sm text-amber-700 mt-0.5">
                  Ensure photos are cropped, color-corrected, and ready for clients before uploading.
                </p>
              </div>
              <button phx-click="dismiss_warning" class="text-amber-400 hover:text-amber-600 text-lg leading-none shrink-0">✕</button>
            </div>
          <% end %>

          <form id="upload-form" phx-submit="save" phx-change="validate">
            <div class="flex flex-wrap gap-6 mb-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Category</label>
                <select name="category" class="rounded-lg border-gray-300 text-sm focus:border-amber-500 focus:ring-amber-500">
                  <option value="windows">Windows</option>
                  <option value="exterior">Exterior</option>
                  <option value="doors">Doors</option>
                  <option value="general">General</option>
                </select>
              </div>
              <div class="flex items-end gap-2">
                <input
                  type="checkbox"
                  name="featured"
                  value="true"
                  id="featured-check"
                  class="rounded border-gray-300 text-amber-600 focus:ring-amber-500"
                />
                <label for="featured-check" class="text-sm font-medium text-gray-700">
                  Feature in hero slideshow
                </label>
              </div>
            </div>

            <div
              class="border-2 border-dashed border-gray-300 rounded-lg p-10 text-center hover:border-amber-400 transition-colors cursor-pointer"
              phx-drop-target={@uploads.photo.ref}
            >
              <.live_file_input upload={@uploads.photo} class="hidden" />
              <div class="text-4xl mb-3">📷</div>
              <p class="text-gray-600 text-sm">
                Drop photos here or
                <label for={@uploads.photo.ref} class="text-amber-600 font-semibold cursor-pointer hover:underline">
                  browse files
                </label>
              </p>
              <p class="text-gray-400 text-xs mt-1">JPG, PNG, WEBP · max 10MB each · up to 5 at a time</p>
            </div>

            <%= if length(@uploads.photo.entries) > 0 do %>
              <div class="mt-5 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
                <%= for entry <- @uploads.photo.entries do %>
                  <div class="relative border rounded-lg overflow-hidden bg-gray-50">
                    <.live_img_preview entry={entry} class="w-full h-28 object-cover" />
                    <div class="p-2">
                      <p class="text-xs text-gray-600 truncate"><%= entry.client_name %></p>
                      <div class="mt-1 h-1.5 bg-gray-200 rounded-full overflow-hidden">
                        <div class="h-full bg-amber-500 transition-all duration-300" style={"width: #{entry.progress}%"} />
                      </div>
                    </div>
                    <button
                      type="button"
                      phx-click="cancel_upload"
                      phx-value-ref={entry.ref}
                      class="absolute top-1 right-1 bg-red-500 text-white rounded-full w-5 h-5 text-xs flex items-center justify-center leading-none hover:bg-red-600"
                    >×</button>
                    <%= for err <- upload_errors(@uploads.photo, entry) do %>
                      <p class="text-xs text-red-500 px-2 pb-1"><%= error_to_string(err) %></p>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>

            <%= for err <- upload_errors(@uploads.photo) do %>
              <p class="text-sm text-red-500 mt-2"><%= error_to_string(err) %></p>
            <% end %>

            <div class="mt-6">
              <button
                type="submit"
                class="bg-amber-600 hover:bg-amber-700 disabled:opacity-40 disabled:cursor-not-allowed text-white font-semibold px-6 py-2.5 rounded-lg transition-colors"
                disabled={
                  length(@uploads.photo.entries) == 0 or
                    upload_errors(@uploads.photo) != [] or
                    Enum.any?(@uploads.photo.entries, &(upload_errors(@uploads.photo, &1) != []))
                }
              >
                Upload <%= length(@uploads.photo.entries) %> Photo<%= if length(@uploads.photo.entries) != 1, do: "s" %>
              </button>
            </div>
          </form>
        </div>

        <%!-- All Photos --%>
        <div class="bg-white rounded-xl shadow-sm overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-100">
            <h2 class="font-semibold text-gray-800">
              All Photos
              <span class="text-sm font-normal text-gray-400 ml-1">(<%= length(@photos) %>)</span>
            </h2>
          </div>

          <%= if length(@photos) == 0 do %>
            <div class="text-center py-16 text-gray-400">
              <div class="text-5xl mb-3">🖼️</div>
              <p>No photos yet.</p>
            </div>
          <% else %>
            <div class="divide-y divide-gray-100">
              <%= for photo <- @photos do %>
                <div class="flex items-center gap-4 px-6 py-4">
                  <img src={photo.url} alt={photo.filename} class="w-16 h-16 object-cover rounded-lg shrink-0 bg-gray-100" />
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate"><%= photo.filename %></p>
                    <div class="flex gap-1.5 mt-1 flex-wrap">
                      <span class="inline-block text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full">
                        <%= photo.category %>
                      </span>
                      <%= if photo.approved do %>
                        <span class="inline-block text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full">
                          approved
                        </span>
                      <% else %>
                        <span class="inline-block text-xs bg-orange-100 text-orange-700 px-2 py-0.5 rounded-full">
                          pending
                        </span>
                      <% end %>
                      <%= if photo.featured do %>
                        <span class="inline-block text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">
                          ★ featured
                        </span>
                      <% end %>
                    </div>
                  </div>
                  <div class="flex items-center gap-2 shrink-0">
                    <%= if photo.approved do %>
                      <button
                        type="button"
                        phx-click="toggle_featured"
                        phx-value-id={photo.id}
                        class={[
                          "text-xs px-3 py-1.5 rounded-lg border font-medium transition-colors",
                          if(photo.featured,
                            do: "border-amber-300 text-amber-700 bg-amber-50 hover:bg-amber-100",
                            else: "border-gray-300 text-gray-600 hover:bg-gray-50")
                        ]}
                      >
                        <%= if photo.featured, do: "Unfeature", else: "Feature" %>
                      </button>
                    <% else %>
                      <button
                        type="button"
                        phx-click="approve"
                        phx-value-id={photo.id}
                        class="text-xs px-3 py-1.5 rounded-lg border font-medium transition-colors border-green-300 text-green-700 hover:bg-green-50"
                      >
                        Approve
                      </button>
                    <% end %>
                    <button
                      type="button"
                      phx-click="delete"
                      phx-value-id={photo.id}
                      data-confirm="Delete this photo?"
                      class="text-xs px-3 py-1.5 rounded-lg border border-red-300 text-red-600 hover:bg-red-50 font-medium transition-colors"
                    >
                      Delete
                    </button>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>

      </div>
    </div>
    """
  end

  defp error_to_string(:too_large), do: "File too large (max 10MB)"
  defp error_to_string(:too_many_files), do: "Too many files (max 5)"
  defp error_to_string(:not_accepted), do: "Only JPG, PNG, and WEBP files accepted"
  defp error_to_string(err), do: "Upload error: #{inspect(err)}"
end
