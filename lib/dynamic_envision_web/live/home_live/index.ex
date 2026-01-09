defmodule DynamicEnvisionWeb.HomeLive.Index do
  use DynamicEnvisionWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Dynamic Envision Solutions")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white">
      <header class="bg-white shadow">
        <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <h1 class="text-3xl font-bold text-gray-900">
            Dynamic Envision Solutions
          </h1>
          <p class="mt-2 text-lg text-gray-600">
            Converting from React to Phoenix LiveView
          </p>
        </div>
      </header>

      <main>
        <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <div class="px-4 py-6 sm:px-0">
            <div class="border-4 border-dashed border-gray-200 rounded-lg h-96 flex items-center justify-center">
              <div class="text-center">
                <h2 class="text-2xl font-semibold text-gray-900 mb-4">
                  Phoenix LiveView Application
                </h2>
                <p class="text-gray-600 mb-8">
                  Conversion in progress...
                </p>
                <div class="space-y-2 text-left max-w-md mx-auto">
                  <div class="flex items-center">
                    <span class="text-green-500 mr-2">✓</span>
                    <span>Phoenix 1.7 project initialized</span>
                  </div>
                  <div class="flex items-center">
                    <span class="text-green-500 mr-2">✓</span>
                    <span>Asset pipeline configured</span>
                  </div>
                  <div class="flex items-center">
                    <span class="text-green-500 mr-2">✓</span>
                    <span>21 images migrated</span>
                  </div>
                  <div class="flex items-center">
                    <span class="text-green-500 mr-2">✓</span>
                    <span>Test infrastructure ready</span>
                  </div>
                  <div class="flex items-center">
                    <span class="text-yellow-500 mr-2">→</span>
                    <span>Next: PhotoShuffle module</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
    """
  end
end
