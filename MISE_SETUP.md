# Mise Setup Guide

This project uses [mise](https://mise.jdx.dev/) for managing Elixir, Erlang, and Node.js versions.

## Why Mise?

- **Faster** - Written in Rust, significantly faster than asdf
- **Modern** - Better UX and more features
- **Compatible** - Works with `.tool-versions` files
- **All-in-one** - Manages environment variables and tasks too

## Installation

### Quick Install (Linux/macOS)

```bash
curl https://mise.run | sh
```

### Manual Install

```bash
# Download the latest release
curl -L https://github.com/jdx/mise/releases/latest/download/mise-latest-linux-x64 -o ~/.local/bin/mise
chmod +x ~/.local/bin/mise

# Add to your shell
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
# OR for zsh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
```

### Via Package Managers

```bash
# Homebrew (macOS/Linux)
brew install mise

# APT (Ubuntu/Debian) - requires adding PPA
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update
sudo apt install -y mise
```

## Project Setup

Once mise is installed, navigate to the project directory and run:

```bash
cd /path/to/dynamic-envision

# Install all tools defined in .mise.toml
mise install

# Verify installation
mise doctor
```

This will install:
- **Elixir 1.18.1** - Latest stable release
- **Erlang/OTP 27.2** - Compatible with Elixir 1.18
- **Node.js 20.11.1** - LTS version for asset compilation

## Activating the Environment

Mise automatically activates the environment when you `cd` into the project directory (if you've set up shell integration).

### Manual Activation

If shell integration isn't set up:

```bash
eval "$(mise activate bash)"  # or zsh, fish, etc.
```

### Verify It's Working

```bash
cd dynamic-envision

# Check versions
elixir --version  # Should show Elixir 1.18.1
erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell

node --version    # Should show v20.11.1
```

## Installing Phoenix Dependencies

After mise is set up:

```bash
# Install Elixir dependencies
mix local.hex --force
mix local.rebar --force
mix deps.get

# Create database
mix ecto.create

# Install Node.js dependencies for assets
cd assets
npm install
cd ..

# Run tests to verify setup
mix test

# Start the Phoenix server
mix phx.server
```

Visit http://localhost:4000 to see the application!

## Configuration Files

This project includes:

- **`.mise.toml`** - Main mise configuration (recommended)
- **`.tool-versions`** - Fallback format (asdf compatible)

Both files specify the same versions. Mise will use `.mise.toml` by default.

## Troubleshooting

### Command not found: mise

Make sure mise is in your PATH and shell activation is configured:

```bash
# Check if mise is installed
which mise

# If not in PATH, add it
export PATH="$HOME/.local/bin:$PATH"

# Activate mise for current shell
eval "$(mise activate bash)"
```

### Mise installs but tools fail to install

Check mise status:

```bash
mise doctor
```

Ensure you have build dependencies:

```bash
# Ubuntu/Debian
sudo apt-get install build-essential autoconf m4 libncurses5-dev \
  libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev \
  libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop \
  libxml2-utils libncurses-dev openjdk-11-jdk

# macOS
xcode-select --install
```

### Specific version installation

To use specific versions:

```bash
# List available versions
mise ls-remote elixir
mise ls-remote erlang

# Install specific version
mise install elixir@1.18.1
mise install erlang@27.2
```

### Shell completion

Enable shell completion for better UX:

```bash
# Bash
mise completion bash > /etc/bash_completion.d/mise

# Zsh
mise completion zsh > /usr/local/share/zsh/site-functions/_mise

# Fish
mise completion fish > ~/.config/fish/completions/mise.fish
```

## Useful Mise Commands

```bash
# Show current versions
mise current

# List installed tools
mise list

# Update all tools
mise upgrade

# Uninstall a tool
mise uninstall elixir@1.18.1

# Show mise configuration
mise settings

# Check for issues
mise doctor

# Prune unused versions
mise prune
```

## VS Code Integration

If using VS Code, add to `.vscode/settings.json`:

```json
{
  "elixirLS.projectDir": ".",
  "elixir.useLanguageServer": true,
  "mise.enable": true
}
```

## Alternative: Using System Elixir

If you prefer not to use mise, you can install Elixir system-wide:

```bash
# Ubuntu/Debian
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang elixir

# macOS
brew install elixir

# Verify
elixir --version
```

## CI/CD with Mise

For GitHub Actions, use the mise-action:

```yaml
- uses: jdx/mise-action@v2
  with:
    version: 2024.1.0
    install: true
```

Or cache mise installations:

```yaml
- uses: actions/cache@v3
  with:
    path: ~/.local/share/mise
    key: ${{ runner.os }}-mise-${{ hashFiles('.mise.toml') }}

- name: Install mise
  run: curl https://mise.run | sh

- name: Install tools
  run: mise install
```

## More Information

- [Mise Documentation](https://mise.jdx.dev/)
- [Elixir Installation](https://elixir-lang.org/install.html)
- [Phoenix Installation](https://hexdocs.pm/phoenix/installation.html)

## Quick Start Checklist

- [ ] Install mise
- [ ] Activate mise in shell (`eval "$(mise activate bash)"`)
- [ ] Run `mise install` in project directory
- [ ] Run `mise doctor` to verify
- [ ] Run `mix deps.get` to install Elixir dependencies
- [ ] Run `mix ecto.create` to create database
- [ ] Run `cd assets && npm install` for Node dependencies
- [ ] Run `mix test` to verify tests pass
- [ ] Run `mix phx.server` to start the application
- [ ] Visit http://localhost:4000

You're ready to go! 🚀
