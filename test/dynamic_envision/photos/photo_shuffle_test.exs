defmodule DynamicEnvision.Photos.PhotoShuffleTest do
  use ExUnit.Case, async: true

  import Mox

  alias DynamicEnvision.Photos.{PhotoShuffle, Image}

  # Make sure mocks are verified after each test
  setup :verify_on_exit!

  describe "process_images/3" do
    test "processes images successfully from a directory" do
      # Arrange
      path = "/test/images/windows"
      category = "Windows"

      image_paths = [
        "/test/images/windows/IMG_5366.jpg",
        "/test/images/windows/IMG_8427.jpg",
        "/test/images/windows/beautiful-window.png"
      ]

      DynamicEnvision.Photos.FileSystemMock
      |> expect(:list_images, fn ^path -> {:ok, image_paths} end)
      |> expect(:basename, 3, fn path ->
        Path.basename(path)
      end)

      # Act
      result = PhotoShuffle.process_images(path, category)

      # Assert
      assert {:ok, images} = result
      assert length(images) == 3

      # Check first image
      first_image = List.first(images)
      assert %Image{} = first_image
      assert first_image.category == "Windows"
      assert first_image.title != nil
      assert first_image.location != nil
      assert first_image.src =~ "/images/"
      assert first_image.original_path == List.first(image_paths)
    end

    test "returns error when directory cannot be read" do
      # Arrange
      path = "/nonexistent/path"
      category = "Windows"

      DynamicEnvision.Photos.FileSystemMock
      |> expect(:list_images, fn ^path -> {:error, :enoent} end)

      # Act
      result = PhotoShuffle.process_images(path, category)

      # Assert
      assert {:error, :enoent} = result
    end

    test "handles empty directory" do
      # Arrange
      path = "/test/empty"
      category = "Windows"

      DynamicEnvision.Photos.FileSystemMock
      |> expect(:list_images, fn ^path -> {:ok, []} end)

      # Act
      result = PhotoShuffle.process_images(path, category)

      # Assert
      assert {:ok, []} = result
    end

    test "uses custom base_url when provided" do
      # Arrange
      path = "/test/images/windows"
      category = "Windows"
      base_url = "/custom/url"

      image_paths = ["/test/images/windows/IMG_5366.jpg"]

      DynamicEnvision.Photos.FileSystemMock
      |> expect(:list_images, fn ^path -> {:ok, image_paths} end)
      |> expect(:basename, fn path -> Path.basename(path) end)

      # Act
      result = PhotoShuffle.process_images(path, category, base_url: base_url)

      # Assert
      assert {:ok, [image]} = result
      assert image.src =~ base_url
    end
  end

  describe "shuffle_images/2" do
    setup do
      images = [
        Image.new("/img1.jpg", "Image 1", "Windows"),
        Image.new("/img2.jpg", "Image 2", "Windows"),
        Image.new("/img3.jpg", "Image 3", "Windows"),
        Image.new("/img4.jpg", "Image 4", "Windows"),
        Image.new("/img5.jpg", "Image 5", "Windows"),
        Image.new("/img6.jpg", "Image 6", "Windows"),
        Image.new("/img7.jpg", "Image 7", "Windows"),
        Image.new("/img8.jpg", "Image 8", "Windows")
      ]

      {:ok, images: images}
    end

    test "returns empty list when given empty list", %{} do
      result = PhotoShuffle.shuffle_images([], 6)
      assert result == []
    end

    test "returns all images when count is greater than list length", %{images: images} do
      # We have 8 images, request 10
      result = PhotoShuffle.shuffle_images(images, 10)

      assert length(result) == 8
      assert Enum.all?(result, &(&1 in images))
    end

    test "returns exactly count images when available", %{images: images} do
      result = PhotoShuffle.shuffle_images(images, 6)

      assert length(result) == 6
      assert Enum.all?(result, &(&1 in images))
    end

    test "returns shuffled images (not in original order)", %{images: images} do
      # Run multiple times to verify shuffling
      results =
        Enum.map(1..10, fn _ ->
          PhotoShuffle.shuffle_images(images, 8)
        end)

      # At least one result should be different from the original order
      # (statistically very likely with 10 attempts)
      assert Enum.any?(results, fn result -> result != images end)
    end

    test "handles count of 0", %{images: images} do
      result = PhotoShuffle.shuffle_images(images, 0)
      assert result == []
    end

    test "handles single image list", %{} do
      single = [Image.new("/single.jpg", "Single", "Windows")]
      result = PhotoShuffle.shuffle_images(single, 5)

      assert result == single
    end

    test "uses default count of 6 when not specified", %{images: images} do
      result = PhotoShuffle.shuffle_images(images)
      assert length(result) == 6
    end
  end

  describe "generate_title/1" do
    test "generates title for IMG pattern files" do
      assert PhotoShuffle.generate_title("IMG_5366.jpg") ==
               "Professional Installation Project"

      assert PhotoShuffle.generate_title("IMG_8427.JPG") ==
               "Professional Installation Project"

      assert PhotoShuffle.generate_title("img_1234.png") ==
               "Professional Installation Project"
    end

    test "generates title for descriptive filenames with hyphens" do
      assert PhotoShuffle.generate_title("beautiful-window-installation.jpg") ==
               "Beautiful Window Installation"

      assert PhotoShuffle.generate_title("modern-door-design.png") ==
               "Modern Door Design"
    end

    test "generates title for descriptive filenames with underscores" do
      assert PhotoShuffle.generate_title("exterior_renovation_project.jpg") ==
               "Exterior Renovation Project"
    end

    test "generates title for purely numeric filenames" do
      assert PhotoShuffle.generate_title("12345.jpg") == "Project Showcase"
      assert PhotoShuffle.generate_title("999.png") == "Project Showcase"
    end

    test "handles filenames without extensions" do
      assert PhotoShuffle.generate_title("beautiful-window") ==
               "Beautiful Window"
    end

    test "handles empty or whitespace filenames" do
      assert PhotoShuffle.generate_title("") == "Portfolio Project"
      assert PhotoShuffle.generate_title("   ") == "Portfolio Project"
    end

    test "capitalizes each word in descriptive filenames" do
      result = PhotoShuffle.generate_title("custom-window-and-door.jpg")
      assert result == "Custom Window And Door"

      # Each word should be capitalized
      words = String.split(result, " ")
      assert Enum.all?(words, fn word ->
        first = String.first(word)
        first == String.upcase(first)
      end)
    end
  end

  describe "smart_location/2" do
    test "returns consistent location for same path" do
      path = "/test/images/IMG_5366.jpg"

      # Call multiple times
      result1 = PhotoShuffle.smart_location(path, "Windows")
      result2 = PhotoShuffle.smart_location(path, "Windows")
      result3 = PhotoShuffle.smart_location(path, "Windows")

      # Should always return the same location
      assert result1 == result2
      assert result2 == result3
    end

    test "returns different locations for different paths" do
      path1 = "/test/images/IMG_5366.jpg"
      path2 = "/test/images/IMG_8427.jpg"

      result1 = PhotoShuffle.smart_location(path1, "Windows")
      result2 = PhotoShuffle.smart_location(path2, "Windows")

      # Different paths should (usually) return different locations
      # We can't guarantee they'll be different due to hash collisions,
      # but with 13 locations, we can test multiple paths
      paths = Enum.map(1..20, fn i -> "/test/images/IMG_#{i}.jpg" end)
      locations = Enum.map(paths, fn path -> PhotoShuffle.smart_location(path, "Windows") end)

      # We should have at least 2 different locations in our sample
      assert length(Enum.uniq(locations)) > 1
    end

    test "returns a valid location from the locations list" do
      path = "/test/images/IMG_5366.jpg"
      result = PhotoShuffle.smart_location(path, "Windows")

      assert result in PhotoShuffle.locations()
    end

    test "works with different category values" do
      path = "/test/images/IMG_5366.jpg"

      # Category is currently not used, but test that it doesn't break
      result1 = PhotoShuffle.smart_location(path, "Windows")
      result2 = PhotoShuffle.smart_location(path, "Exterior")

      # Should return same location since hash is based on path
      assert result1 == result2
    end
  end

  describe "locations/0" do
    test "returns a list of location strings" do
      result = PhotoShuffle.locations()

      assert is_list(result)
      assert length(result) > 0
      assert Enum.all?(result, &is_binary/1)
    end

    test "includes expected Denver metro locations" do
      result = PhotoShuffle.locations()

      assert "Denver" in result
      assert "Aurora" in result
      assert "Boulder" in result
    end

    test "returns consistent list" do
      # Should return same list each time
      result1 = PhotoShuffle.locations()
      result2 = PhotoShuffle.locations()

      assert result1 == result2
    end
  end

  describe "hash_path/1" do
    test "returns consistent hash for same path" do
      path = "/test/images/IMG_5366.jpg"

      hash1 = PhotoShuffle.hash_path(path)
      hash2 = PhotoShuffle.hash_path(path)

      assert hash1 == hash2
      assert is_integer(hash1)
      assert hash1 >= 0
    end

    test "returns different hashes for different paths" do
      path1 = "/test/images/IMG_5366.jpg"
      path2 = "/test/images/IMG_8427.jpg"

      hash1 = PhotoShuffle.hash_path(path1)
      hash2 = PhotoShuffle.hash_path(path2)

      assert hash1 != hash2
    end

    test "handles empty string" do
      hash = PhotoShuffle.hash_path("")
      assert is_integer(hash)
      assert hash >= 0
    end

    test "returns non-negative integer" do
      paths = [
        "/test/image1.jpg",
        "/test/image2.jpg",
        "/very/long/path/to/some/image/file/IMG_12345.jpg",
        "short.jpg"
      ]

      Enum.each(paths, fn path ->
        hash = PhotoShuffle.hash_path(path)
        assert is_integer(hash)
        assert hash >= 0
      end)
    end
  end

  describe "integration test" do
    test "complete workflow from directory to shuffled images" do
      # Arrange
      path = "/test/images/windows"
      category = "Windows"

      image_paths =
        Enum.map(1..10, fn i ->
          "/test/images/windows/IMG_#{String.pad_leading(to_string(i), 4, "0")}.jpg"
        end)

      DynamicEnvision.Photos.FileSystemMock
      |> expect(:list_images, fn ^path -> {:ok, image_paths} end)
      |> expect(:basename, length(image_paths), fn path ->
        Path.basename(path)
      end)

      # Act
      {:ok, all_images} = PhotoShuffle.process_images(path, category)
      selected = PhotoShuffle.shuffle_images(all_images, 6)

      # Assert
      assert length(all_images) == 10
      assert length(selected) == 6

      # All images should have required fields
      Enum.each(selected, fn image ->
        assert %Image{} = image
        assert image.src != nil
        assert image.title != nil
        assert image.category == category
        assert image.location in PhotoShuffle.locations()
        assert image.original_path in image_paths
      end)

      # Selected should be a subset of all_images
      assert Enum.all?(selected, &(&1 in all_images))
    end
  end
end
