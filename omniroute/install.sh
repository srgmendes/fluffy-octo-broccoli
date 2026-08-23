#!/bin/bash

# OmniRoute installation script
# Clones the official OmniRoute repository and prepares it for local development/deployment

set -e

INSTALL_DIR="${1:-.}"
OMNIROUTE_REPO="https://github.com/diegosouzapw/OmniRoute.git"

echo "📦 Installing OmniRoute..."

if [ ! -d "$INSTALL_DIR/checkout" ]; then
  echo "📥 Cloning OmniRoute repository..."
  mkdir -p "$INSTALL_DIR"
  git clone "$OMNIROUTE_REPO" "$INSTALL_DIR/checkout"
else
  echo "✓ OmniRoute repository already cloned"
  cd "$INSTALL_DIR/checkout"
  git fetch origin
fi

cd "$INSTALL_DIR/checkout"

echo ""
echo "✓ OmniRoute cloned to: $INSTALL_DIR/checkout"
echo ""
echo "📋 Next steps:"
echo ""
echo "  1. Copy the environment template:"
echo "     cp .env.example .env"
echo ""
echo "  2. Edit .env and configure:"
echo "     - INITIAL_PASSWORD: set a strong dashboard password"
echo "     - Any provider API keys for routing (optional, free tiers work)"
echo ""
echo "  3. Install dependencies (requires Node.js 20.12+):"
echo "     npm ci"
echo ""
echo "  4. Build the application:"
echo "     npm run build"
echo ""
echo "  5. Start the server:"
echo "     npm start"
echo "     # or for development:"
echo "     npm run dev"
echo ""
echo "  6. Open the dashboard:"
echo "     http://localhost:20128"
echo ""
echo "📖 Full documentation: https://github.com/diegosouzapw/OmniRoute"
echo "💬 Community: https://discord.gg/U47eFqAXCn"
