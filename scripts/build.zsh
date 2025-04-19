#!/bin/zsh

# Exit on any error
set -e

# Detect platform
OS="$(uname)"

echo "🚧 Cleaning previous build..."
rm -rf dist

echo "📁 Creating dist directories..."
mkdir -p dist
mkdir -p dist/config

echo "📦 Copying files to dist..."
cp -R ./lib/. ./dist/
cp -R ./config/pimp.zshenv ./dist/config/pimp.zshenv

sleep 0.5

# 🔧 Update config path in script
TARGET_FILE="./dist/pimp.zsh"
echo "🛠️  Rewriting config path in $TARGET_FILE..."

if [[ -f "$TARGET_FILE" ]]; then
  if [[ "$OS" == "Darwin" ]]; then
    echo "🍏 macOS detected — using BSD sed"
    sed -i '' 's|\.\./config/pimp2\.zshenv|config/pimp.zshenv|g' "$TARGET_FILE"
  else
    echo "🐧 Linux detected — using GNU sed"
    sed -i 's|\.\./config/pimp2\.zshenv|config/pimp.zshenv|g' "$TARGET_FILE"
  fi
else
  echo "⚠️ $TARGET_FILE not found, skipping sed replacement"
fi

# Extract version
echo "🔍 Extracting version from package.json..."

VERSION=$(grep '"version"' package.json | sed -E 's/.*"version": *"([^"]+)".*/\1/')
echo "$VERSION" > ./dist/.version

echo "✅ Build complete! Version: $VERSION"

