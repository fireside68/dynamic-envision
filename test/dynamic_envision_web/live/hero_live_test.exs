defmodule DynamicEnvisionWeb.HeroLiveTest do
  use DynamicEnvisionWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Mox

  setup :verify_on_exit!

  describe "HeroLive component" do
    test "renders with no images when directories are empty", %{conn: conn} do
      PhotoShuffle.FileSystemMock
      |> stub(:list_images, fn _path -> {:ok, []} end)
      |> stub(:basename, fn path -> Path.basename(path) end)
      |> stub(:file_exists?, fn _path -> false end)

      {:ok, _view, html} = live(conn, "/")

      # Hero section should still render
      assert html =~ "hero-slideshow"
      assert html =~ "What Can We Help You With?"
    end

    test "renders product category cards", %{conn: conn} do
      PhotoShuffle.FileSystemMock
      |> stub(:list_images, fn _path -> {:ok, []} end)
      |> stub(:basename, fn path -> Path.basename(path) end)
      |> stub(:file_exists?, fn _path -> false end)

      {:ok, _view, html} = live(conn, "/")

      # Should display the three product categories
      assert html =~ "Windows"
      assert html =~ "Doors"
      assert html =~ "Exterior"

      # Should have smooth scroll links
      assert html =~ "hero-link-windows"
      assert html =~ "hero-link-doors"
      assert html =~ "hero-link-exterior"
    end

    test "renders trust indicators", %{conn: conn} do
      PhotoShuffle.FileSystemMock
      |> stub(:list_images, fn _path -> {:ok, []} end)
      |> stub(:basename, fn path -> Path.basename(path) end)
      |> stub(:file_exists?, fn _path -> false end)

      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Licensed"
      assert html =~ "Free Estimates"
      assert html =~ "15+ Years Experience"
    end

    test "renders images when provided by file system", %{conn: conn} do
      PhotoShuffle.FileSystemMock
      |> stub(:list_images, fn path ->
        if String.contains?(path, "windows") do
          {:ok, ["/priv/static/design/pictures/windows/IMG_001.jpg"]}
        else
          {:ok, []}
        end
      end)
      |> stub(:basename, fn path -> Path.basename(path) end)
      |> stub(:file_exists?, fn _path -> true end)

      {:ok, _view, html} = live(conn, "/")

      # The hero should render with the Ken Burns slideshow
      assert html =~ "hero-slideshow"
    end
  end
end
