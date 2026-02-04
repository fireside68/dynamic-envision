defmodule DynamicEnvisionWeb.HomeLiveTest do
  use DynamicEnvisionWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Mox

  setup :verify_on_exit!

  setup do
    # Mock the file system to return empty lists for image directories
    # This prevents actual file system access during tests
    PhotoShuffle.FileSystemMock
    |> stub(:list_images, fn _path -> {:ok, []} end)
    |> stub(:basename, fn path -> Path.basename(path) end)
    |> stub(:file_exists?, fn _path -> false end)

    :ok
  end

  describe "Home page" do
    test "renders the home page successfully", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Dynamic Envision Solutions"
    end

    test "displays navigation", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "mobile-menu-hook"
      assert html =~ "nav-services"
    end

    test "displays hero section", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "hero"
      assert html =~ "What Can We Help You With?"
    end

    test "displays services section", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "services"
      assert html =~ "Windows"
      assert html =~ "Doors"
      assert html =~ "Exterior"
    end

    test "displays portfolio section", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "portfolio"
    end

    test "displays footer with copyright", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Dynamic Envision Solutions"
      assert html =~ Integer.to_string(DateTime.utc_now().year)
    end
  end
end
