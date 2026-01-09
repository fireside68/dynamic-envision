# PhotoShuffle

> A reusable Elixir library for managing and shuffling image collections with intelligent metadata generation.

PhotoShuffle provides a clean, testable API for processing images from directories, generating smart metadata, and randomly selecting images for display in portfolios, galleries, and slideshows.

## Features

- 📁 **Directory Processing** - Scan directories for image files
- 🔀 **Random Shuffling** - Randomly select N images from collections
- 🏷️ **Smart Titling** - Generate human-readable titles from filenames
- 📍 **Deterministic Locations** - Consistent location assignment via hashing
- 🧪 **Fully Tested** - 100% test coverage with Mox for mocking
- 🔧 **Behavior-Driven** - Injectable dependencies for easy testing

## Installation

### As Part of Dynamic Envision

The PhotoShuffle module is included in the Dynamic Envision application:

```elixir
alias DynamicEnvision.Photos.PhotoShuffle
alias DynamicEnvision.Photos.Image
```

### As a Standalone Hex Package (Future)

If extracted as a standalone package, add to your `mix.exs`:

```elixir
def deps do
  [
    {:photo_shuffle, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Example

```elixir
alias DynamicEnvision.Photos.PhotoShuffle

# Process images from a directory
{:ok, all_images} = PhotoShuffle.process_images(
  "/priv/static/images/windows",
  "Windows"
)

# Shuffle and select 6 random images
selected = PhotoShuffle.shuffle_images(all_images, 6)

# Use in your LiveView or templates
Enum.each(selected, fn image ->
  IO.puts("#{image.title} in #{image.location}")
end)
```

### Image Processing

Process images from a directory with automatic metadata generation:

```elixir
# Process with default settings
{:ok, images} = PhotoShuffle.process_images(
  "/path/to/images",
  "Windows"
)

# Process with custom base URL
{:ok, images} = PhotoShuffle.process_images(
  "/path/to/images",
  "Exterior",
  base_url: "/custom/images"
)

# Each image has:
# - src: "/images/windows/IMG_5366.jpg"
# - title: "Professional Window Installation"
# - category: "Windows"
# - location: "Denver"
# - original_path: "/priv/static/images/windows/IMG_5366.jpg"
```

### Random Selection

Shuffle and select images for display:

```elixir
# Select 6 random images (default)
portfolio = PhotoShuffle.shuffle_images(all_images)

# Select specific number
hero_images = PhotoShuffle.shuffle_images(all_images, 8)

# Handle empty lists safely
PhotoShuffle.shuffle_images([], 6)  # => []
```

### Title Generation

Generate human-readable titles from filenames:

```elixir
# IMG pattern files
PhotoShuffle.generate_title("IMG_5366.jpg")
# => "Professional Installation Project"

# Descriptive filenames
PhotoShuffle.generate_title("beautiful-window-installation.jpg")
# => "Beautiful Window Installation"

# Numeric filenames
PhotoShuffle.generate_title("12345.png")
# => "Project Showcase"
```

### Location Assignment

Assign consistent locations to images:

```elixir
# Same path always gets same location
location = PhotoShuffle.smart_location("/path/to/IMG_5366.jpg", "Windows")
# => "Denver"  (always "Denver" for this path)

# Get all available locations
locations = PhotoShuffle.locations()
# => ["Denver", "Aurora", "Boulder", "Fort Collins", ...]
```

## Architecture

### Modules

```
lib/dynamic_envision/photos/
├── photo_shuffle.ex              # Main API module
├── image.ex                      # Image struct
├── file_system_behaviour.ex      # File system contract
└── file_system/
    └── local.ex                  # Production implementation
```

### Image Struct

```elixir
%DynamicEnvision.Photos.Image{
  src: "/images/windows/IMG_5366.jpg",
  title: "Professional Window Installation",
  category: "Windows",
  location: "Denver",
  original_path: "/priv/static/images/windows/IMG_5366.jpg"
}
```

### Behavior Pattern

PhotoShuffle uses the behavior pattern for file system operations, making it easy to test:

```elixir
# Production: Uses real file system
config :dynamic_envision,
  file_system: DynamicEnvision.Photos.FileSystem.Local

# Test: Uses mock
config :dynamic_envision,
  file_system: DynamicEnvision.Photos.FileSystemMock
```

## Testing

### With Mox

PhotoShuffle is designed to be easily testable with Mox:

```elixir
defmodule MyAppTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  test "processes images" do
    # Mock file system behavior
    DynamicEnvision.Photos.FileSystemMock
    |> expect(:list_images, fn _path ->
      {:ok, ["/path/to/image1.jpg", "/path/to/image2.jpg"]}
    end)
    |> expect(:basename, 2, fn path ->
      Path.basename(path)
    end)

    # Test your code
    {:ok, images} = PhotoShuffle.process_images("/test/path", "Windows")
    assert length(images) == 2
  end
end
```

### Running Tests

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test file
mix test test/dynamic_envision/photos/photo_shuffle_test.exs
```

## Configuration

### Development & Production

```elixir
# config/config.exs
config :dynamic_envision,
  file_system: DynamicEnvision.Photos.FileSystem.Local
```

### Testing

```elixir
# config/test.exs
config :dynamic_envision,
  file_system: DynamicEnvision.Photos.FileSystemMock
```

## Advanced Usage

### In a Phoenix LiveView

```elixir
defmodule MyAppWeb.PortfolioLive do
  use MyAppWeb, :live_view

  alias DynamicEnvision.Photos.PhotoShuffle

  def mount(_params, _session, socket) do
    {:ok, load_images(socket)}
  end

  def handle_event("refresh", _params, socket) do
    {:noreply, load_images(socket)}
  end

  defp load_images(socket) do
    {:ok, all_images} = PhotoShuffle.process_images(
      Application.app_dir(:my_app, "priv/static/images/portfolio"),
      "Portfolio"
    )

    selected = PhotoShuffle.shuffle_images(all_images, 6)

    assign(socket, images: selected)
  end
end
```

### Custom File System Implementation

Implement the behavior for custom storage (e.g., S3):

```elixir
defmodule MyApp.FileSystem.S3 do
  @behaviour DynamicEnvision.Photos.FileSystemBehaviour

  @impl true
  def list_images(path) do
    # Implement S3 listing logic
    {:ok, ["s3://bucket/image1.jpg", "s3://bucket/image2.jpg"]}
  end

  @impl true
  def file_exists?(path) do
    # Implement S3 existence check
    ExAws.S3.head_object("bucket", path) |> ExAws.request!()
    true
  rescue
    _ -> false
  end

  @impl true
  def basename(path) do
    Path.basename(path)
  end
end
```

## API Reference

### Main Functions

- `process_images/3` - Process images from a directory
- `shuffle_images/2` - Randomly select N images
- `generate_title/1` - Generate title from filename
- `smart_location/2` - Assign deterministic location
- `locations/0` - Get list of available locations

See module documentation for detailed function specs and examples.

## Performance

- **Processing**: O(n) where n is the number of images
- **Shuffling**: O(n log n) due to Enum.shuffle/1
- **Location Assignment**: O(1) deterministic hashing

## Roadmap

### Future Enhancements

- [ ] Support for remote storage (S3, CloudStorage, etc.)
- [ ] Image metadata extraction (EXIF data)
- [ ] Caching layer for processed images
- [ ] Custom location lists
- [ ] AI-powered title generation
- [ ] Image similarity detection

### Hex Package Extraction

To extract as a standalone Hex package:

1. Copy `lib/dynamic_envision/photos/` to new project
2. Rename module namespace (e.g., `PhotoShuffle`)
3. Create standalone `mix.exs`
4. Add comprehensive documentation
5. Publish to Hex.pm

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass (`mix test`)
5. Submit a pull request

## License

Copyright © 2024 Dynamic Envision Solutions

## Credits

Created as part of the Dynamic Envision Solutions Phoenix conversion project.

Designed to be extracted as a reusable library for the Elixir community.
