#!/bin/bash
set -e

# Configuration
APP_NAME="DodoNest"
VERSION="${1:-1.0.0}"
BUILD_DIR="build"
DERIVED_DATA="$BUILD_DIR/DerivedData"
APP_PATH="$DERIVED_DATA/Build/Products/Release/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"

echo "Building $APP_NAME version $VERSION..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Generate Xcode project
echo "Generating Xcode project..."
xcodegen generate

# Build release version
echo "Compiling..."
xcodebuild -project "$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    clean build

echo "App bundle created at $APP_PATH"

# Create DMG
echo "Creating DMG..."
rm -f "$BUILD_DIR/$DMG_NAME"

# Create a temporary directory for DMG contents
DMG_TEMP="$BUILD_DIR/dmg-temp"
mkdir -p "$DMG_TEMP"
cp -R "$APP_PATH" "$DMG_TEMP/"

# Create symbolic link to Applications folder
ln -s /Applications "$DMG_TEMP/Applications"

# Create the DMG
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_TEMP" -ov -format UDZO "$BUILD_DIR/$DMG_NAME"

# Clean up
rm -rf "$DMG_TEMP"

echo ""
echo "Build complete!"
echo "  App: $APP_PATH"
echo "  DMG: $BUILD_DIR/$DMG_NAME"
echo ""

# Calculate SHA256 for Homebrew
SHA256=$(shasum -a 256 "$BUILD_DIR/$DMG_NAME" | awk '{print $1}')
echo "SHA256: $SHA256"
echo ""
echo "Use this SHA256 in the Homebrew Cask formula."
