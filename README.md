# Dynamic Envision Solutions - Phoenix LiveView Application

> **Note:** This application is being converted from React + Vite to Phoenix LiveView with Elixir 1.18

A modern, real-time web application for Dynamic Envision Solutions, a window and door installation company serving the Denver metro area.

## Technology Stack

- **Elixir 1.18** - Functional programming language
- **Phoenix 1.7** - Web framework for scalable applications
- **Phoenix LiveView 1.0** - Real-time, server-rendered UI
- **PostgreSQL** - Relational database
- **Tailwind CSS 3.4** - Utility-first CSS framework

## Getting Started

### Quick Setup with Mise (Recommended)

This project uses [mise](https://mise.jdx.dev/) for managing Elixir, Erlang, and Node.js versions.

```bash
# Install mise (if not already installed)
curl https://mise.run | sh

# Run the setup script
./setup.sh
```

The setup script will:
- Install Elixir 1.18.1, Erlang 27.2, and Node.js 20.11.1
- Install all dependencies
- Create the database
- Run tests to verify everything works

See [`MISE_SETUP.md`](MISE_SETUP.md) for detailed mise installation and usage instructions.

### Manual Installation

If you have Elixir, Erlang, and Node.js already installed:

```bash
# Install dependencies
mix deps.get

# Create and migrate database
mix ecto.setup

# Install Node.js dependencies
cd assets && npm install

# Start Phoenix server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) in your browser.

### Prerequisites

- Elixir 1.18+
- Erlang/OTP 27+
- PostgreSQL 14+
- Node.js 20+ (for asset compilation)

## Testing

```bash
# Run all tests
mix test

# Run with coverage
mix coveralls.html

# Code quality
mix credo --strict
mix dialyzer
```

## Features

- **Dynamic Hero Slideshow** with Ken Burns effect
- **Portfolio Grid** with randomized display
- **Contact Form** with real-time validation
- **PhotoShuffle Module** - Reusable image management library
- **Responsive Design** - Mobile-first approach

## Learn More

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/)
- [Elixir](https://elixir-lang.org/)
