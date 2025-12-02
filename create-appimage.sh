#!/bin/bash
# AppImage Creator for Qt6 Applications
# Creates a single-file executable with all dependencies included
# Works for x86_64 and ARM64 (Raspberry Pi 5)

set -e

APP_NAME="GLADIS"
BUILD_DIR="build-local"
VERSION="1.0"
ARCH=$(uname -m)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}   AppImage Creator for Qt6${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if appimagetool is available
if ! command -v appimagetool &> /dev/null; then
    echo -e "${YELLOW}AppImageTool not found. Downloading...${NC}"

    # Download appimagetool based on architecture
    if [ "$ARCH" = "x86_64" ]; then
        APPIMAGETOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    elif [ "$ARCH" = "aarch64" ]; then
        APPIMAGETOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-aarch64.AppImage"
    else
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
    fi

    wget -q --show-progress "$APPIMAGETOOL_URL" -O appimagetool
    chmod +x appimagetool
    APPIMAGETOOL="./appimagetool"
else
    APPIMAGETOOL="appimagetool"
fi

# First, run the deploy script to create the bundle
echo -e "${YELLOW}Creating application bundle first...${NC}"
if [ ! -f "deploy.sh" ]; then
    echo -e "${RED}ERROR: deploy.sh not found!${NC}"
    exit 1
fi

./deploy.sh

# Check if bundle was created
if [ ! -d "deploy/$APP_NAME" ]; then
    echo -e "${RED}ERROR: Bundle not created by deploy.sh${NC}"
    exit 1
fi

# Create AppDir structure
APPDIR="${APP_NAME}.AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR"

echo -e "${YELLOW}Creating AppDir structure...${NC}"

# Copy the entire bundle into AppDir
cp -r "deploy/$APP_NAME"/* "$APPDIR/"

# Create AppRun script
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
# AppImage entry point

# Get the directory where AppImage is mounted
APPDIR="$(dirname "$(readlink -f "$0")")"

# Set up environment for bundled Qt
export LD_LIBRARY_PATH="$APPDIR/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$APPDIR/plugins"
export QML_IMPORT_PATH="$APPDIR/qml"
export QML2_IMPORT_PATH="$APPDIR/qml"
export QT_QPA_PLATFORM_PLUGIN_PATH="$APPDIR/plugins/platforms"

# For Raspberry Pi: detect and set appropriate platform
if [ -f /proc/device-tree/model ] && grep -q "Raspberry Pi" /proc/device-tree/model; then
    # Check if running in X11 session
    if [ -n "$DISPLAY" ]; then
        export QT_QPA_PLATFORM=xcb
    else
        export QT_QPA_PLATFORM=eglfs
    fi
fi

# Run the application
exec "$APPDIR/GLADIS" "$@"
EOF

chmod +x "$APPDIR/AppRun"

# Create desktop entry
cat > "$APPDIR/$APP_NAME.desktop" << EOF
[Desktop Entry]
Type=Application
Name=GLADIS
Comment=GLADIS Application
Exec=GLADIS
Icon=$APP_NAME
Categories=Game;Sports;
Terminal=false
EOF

# Create a simple icon (you can replace this with actual icon)
# For now, create a symbolic link to qt.conf as placeholder
# In production, you should have a .png or .svg icon
if [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$APPDIR/$APP_NAME.png"
elif [ -f "assets/icon.svg" ]; then
    cp "assets/icon.svg" "$APPDIR/$APP_NAME.svg"
else
    # Create a placeholder icon indicator
    touch "$APPDIR/.DirIcon"
fi

# Create the AppImage
echo -e "${YELLOW}Building AppImage...${NC}"
OUTPUT="${APP_NAME}-v${VERSION}-${ARCH}.AppImage"

# Set ARCH environment variable for appimagetool
export ARCH

# Build AppImage
$APPIMAGETOOL "$APPDIR" "$OUTPUT" -n

if [ -f "$OUTPUT" ]; then
    chmod +x "$OUTPUT"
    SIZE=$(du -sh "$OUTPUT" | cut -f1)

    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}   AppImage Created! ✅${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${YELLOW}AppImage Information:${NC}"
    echo "  File: $OUTPUT"
    echo "  Size: $SIZE"
    echo "  Architecture: $ARCH"
    echo ""
    echo -e "${YELLOW}To run locally:${NC}"
    echo "  ./$OUTPUT"
    echo ""
    echo -e "${YELLOW}To deploy to Raspberry Pi:${NC}"
    echo "  scp $OUTPUT pi@raspberrypi.local:~/"
    echo "  ssh pi@raspberrypi.local './$OUTPUT'"
    echo ""
    echo -e "${GREEN}✨ Single file with ZERO external dependencies! ✨${NC}"
    echo -e "${GREEN}✨ Works on any Linux system without Qt6 installed! ✨${NC}"
    echo ""
else
    echo -e "${RED}ERROR: AppImage creation failed!${NC}"
    exit 1
fi
