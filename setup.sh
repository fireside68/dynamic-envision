#!/usr/bin/env bash
set -e

echo "🚀 Setting up Dynamic Envision Solutions (Phoenix/Elixir)..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if mise is installed
if ! command -v mise &> /dev/null; then
    echo -e "${RED}❌ mise is not installed${NC}"
    echo ""
    echo "Please install mise first:"
    echo "  curl https://mise.run | sh"
    echo ""
    echo "Or see MISE_SETUP.md for alternative installation methods"
    exit 1
fi

echo -e "${GREEN}✓${NC} mise is installed"

# Check mise version
MISE_VERSION=$(mise --version | head -n 1)
echo "  Version: $MISE_VERSION"
echo ""

# Install tools from .mise.toml
echo "📦 Installing Elixir, Erlang, and Node.js via mise..."
mise install

echo ""
echo -e "${GREEN}✓${NC} Tools installed successfully"
echo ""

# Verify installations
echo "🔍 Verifying installations..."
echo ""

if command -v elixir &> /dev/null; then
    ELIXIR_VERSION=$(elixir --version | grep Elixir | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Elixir $ELIXIR_VERSION"
else
    echo -e "${RED}❌ Elixir not found${NC}"
    exit 1
fi

if command -v erl &> /dev/null; then
    ERL_VERSION=$(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)
    echo -e "${GREEN}✓${NC} Erlang/OTP $ERL_VERSION"
else
    echo -e "${RED}❌ Erlang not found${NC}"
    exit 1
fi

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓${NC} Node.js $NODE_VERSION"
else
    echo -e "${RED}❌ Node.js not found${NC}"
    exit 1
fi

echo ""
echo "📚 Installing Hex and Rebar..."
mix local.hex --force
mix local.rebar --force

echo ""
echo "📦 Installing Elixir dependencies..."
mix deps.get

echo ""
echo "🗄️  Setting up database..."
if mix ecto.create; then
    echo -e "${GREEN}✓${NC} Database created"
else
    echo -e "${YELLOW}⚠${NC}  Database might already exist or PostgreSQL not running"
fi

echo ""
echo "📦 Installing Node.js dependencies..."
cd assets
npm install
cd ..

echo ""
echo "✨ Compiling assets..."
mix assets.build

echo ""
echo "🧪 Running tests to verify setup..."
if mix test; then
    echo ""
    echo -e "${GREEN}✓${NC} All tests passed!"
else
    echo ""
    echo -e "${YELLOW}⚠${NC}  Some tests failed. Check output above."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To start the Phoenix server:"
echo "  ${GREEN}mix phx.server${NC}"
echo ""
echo "Then visit: ${GREEN}http://localhost:4000${NC}"
echo ""
echo "Useful commands:"
echo "  mix test              - Run all tests"
echo "  mix test --cover      - Run tests with coverage"
echo "  mix credo --strict    - Code quality check"
echo "  mix format            - Format code"
echo "  mix phx.routes        - Show all routes"
echo ""
echo "Happy coding! 🎉"
