defmodule DynamicEnvisionWeb.PortfolioLiveTest do
  use DynamicEnvisionWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Mox

  setup :verify_on_exit!

  describe "PortfolioLive component" do
    test "renders portfolio section", %{conn: conn} do
      PhotoShuffle.FileSystemMock
      |> stub(:list_images, fn _path -> {:ok, []} end)
      |> stub(:basename, fn path -> Path.basename(path) end)
      |> stub(:file_exists?, fn _path -> false end)

      {:ok, _view, html} = live(conn, "/")

      assert html =~ "portfolio"
      assert html =~ "Recent Projects"
    end

    test "renders empty state when no images available", %{conn: conn} do
      PhotoShuffle.FileSystemMock
      |> stub(:list_images, fn _path -> {:ok, []} end)
      |> stub(:basename, fn path -> Path.basename(path) end)
      |> stub(:file_exists?, fn _path -> false end)

      {:ok, _view, html} = live(conn, "/")

      # Portfolio section should still be present
      assert html =~ "portfolio"
    end

    test "can shuffle images via event", %{conn: conn} do
      PhotoShuffle.FileSystemMock
      |> stub(:list_images, fn _path -> {:ok, []} end)
      |> stub(:basename, fn path -> Path.basename(path) end)
      |> stub(:file_exists?, fn _path -> false end)

      {:ok, view, _html} = live(conn, "/")

      # Send shuffle event to the portfolio component
      # The component should handle this gracefully even with no images
      send(view.pid, {:shuffle_portfolio, []})

      # Page should still render without errors
      html = render(view)
      assert html =~ "portfolio"
    end
  end
end
