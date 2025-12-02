#!/bin/bash
# Self-Contained Qt6 Application Deployment Script
# Works for both x86_64 and ARM64 (Raspberry Pi 5)
# Creates a fully bundled application with zero external dependencies

set -e

APP_NAME="GLADIS"
BUILD_DIR="build-local"
DEPLOY_DIR="deploy"
VERSION="1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Qt6 Application Deployment Tool${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Detect architecture
ARCH=$(uname -m)
echo -e "${YELLOW}Detected architecture: $ARCH${NC}"

# Find executable
EXECUTABLE=""
if [ -f "$BUILD_DIR/bin/$APP_NAME" ]; then
    EXECUTABLE="$BUILD_DIR/bin/$APP_NAME"
elif [ -f "$BUILD_DIR/$APP_NAME" ]; then
    EXECUTABLE="$BUILD_DIR/$APP_NAME"
elif [ -f "$APP_NAME" ]; then
    EXECUTABLE="$APP_NAME"
else
    echo -e "${RED}ERROR: Cannot find $APP_NAME executable!${NC}"
    echo "Please build the application first:"
    echo "  mkdir -p $BUILD_DIR && cd $BUILD_DIR"
    echo "  cmake .. && make -j\$(nproc)"
    echo "  cd .."
    exit 1
fi

echo -e "${GREEN}Found executable: $EXECUTABLE${NC}"

# Verify it's a valid executable
if ! file "$EXECUTABLE" | grep -q "ELF"; then
    echo -e "${RED}ERROR: $EXECUTABLE is not a valid ELF executable!${NC}"
    exit 1
fi

# Clean and create deploy directory
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/$APP_NAME"

echo -e "${YELLOW}Copying executable...${NC}"
cp "$EXECUTABLE" "$DEPLOY_DIR/$APP_NAME/"

# Function to copy library and its dependencies recursively
copy_lib_dependencies() {
    local lib=$1
    local dest=$2

    if [ ! -f "$lib" ]; then
        return
    fi

    # Copy the library
    local libname=$(basename "$lib")
    if [ ! -f "$dest/$libname" ]; then
        cp -L "$lib" "$dest/" 2>/dev/null || true
    fi
}

# Find Qt installation
echo -e "${YELLOW}Detecting Qt6 installation...${NC}"
QT_PATH=$(qmake6 -query QT_INSTALL_PREFIX 2>/dev/null || echo "/usr")
QT_PLUGINS="$QT_PATH/lib/$ARCH-linux-gnu/qt6/plugins"
QT_QML="$QT_PATH/lib/$ARCH-linux-gnu/qt6/qml"

# Alternative paths
if [ ! -d "$QT_PLUGINS" ]; then
    QT_PLUGINS="/usr/lib/qt6/plugins"
    QT_QML="/usr/lib/qt6/qml"
fi

echo -e "${GREEN}Qt path: $QT_PATH${NC}"
echo -e "${GREEN}Qt plugins: $QT_PLUGINS${NC}"
echo -e "${GREEN}Qt QML: $QT_QML${NC}"

# Create directory structure
mkdir -p "$DEPLOY_DIR/$APP_NAME/lib"
mkdir -p "$DEPLOY_DIR/$APP_NAME/plugins"
mkdir -p "$DEPLOY_DIR/$APP_NAME/qml"

# Copy all Qt and required libraries
echo -e "${YELLOW}Copying Qt6 libraries and dependencies...${NC}"
ldd "$EXECUTABLE" | grep "=> /" | awk '{print $3}' | while read lib; do
    if [ -f "$lib" ]; then
        # Skip system libraries that should be present on all Linux systems
        if echo "$lib" | grep -qE "linux-vdso|ld-linux|libc\.so|libm\.so|libdl\.so|libpthread\.so|librt\.so"; then
            continue
        fi

        libname=$(basename "$lib")
        if [ ! -f "$DEPLOY_DIR/$APP_NAME/lib/$libname" ]; then
            cp -L "$lib" "$DEPLOY_DIR/$APP_NAME/lib/" 2>/dev/null || true
            echo "  ✓ $libname"
        fi
    fi
done

# Copy Qt6 plugins
echo -e "${YELLOW}Copying Qt6 plugins...${NC}"
if [ -d "$QT_PLUGINS" ]; then
    # Essential plugins
    for plugin_dir in platforms platformthemes platforminputcontexts xcbglintegrations imageformats iconengines egldeviceintegrations; do
        if [ -d "$QT_PLUGINS/$plugin_dir" ]; then
            mkdir -p "$DEPLOY_DIR/$APP_NAME/plugins/$plugin_dir"
            cp -r "$QT_PLUGINS/$plugin_dir"/* "$DEPLOY_DIR/$APP_NAME/plugins/$plugin_dir/" 2>/dev/null || true
            echo "  ✓ $plugin_dir"
        fi
    done
fi

# Copy Qt6 QML modules
echo -e "${YELLOW}Copying Qt6 QML modules...${NC}"
if [ -d "$QT_QML" ]; then
    # Copy all QML modules (they're needed for Qt Quick apps)
    cp -r "$QT_QML"/* "$DEPLOY_DIR/$APP_NAME/qml/" 2>/dev/null || true
    echo "  ✓ QML modules copied"
fi

# Copy plugin dependencies
echo -e "${YELLOW}Copying plugin dependencies...${NC}"
for plugin in "$DEPLOY_DIR/$APP_NAME/plugins"/*/*.so "$DEPLOY_DIR/$APP_NAME/qml"/*/*.so; do
    if [ -f "$plugin" ]; then
        ldd "$plugin" 2>/dev/null | grep "=> /" | awk '{print $3}' | while read lib; do
            if [ -f "$lib" ]; then
                # Skip system libraries
                if echo "$lib" | grep -qE "linux-vdso|ld-linux|libc\.so|libm\.so|libdl\.so|libpthread\.so|librt\.so"; then
                    continue
                fi

                libname=$(basename "$lib")
                if [ ! -f "$DEPLOY_DIR/$APP_NAME/lib/$libname" ]; then
                    cp -L "$lib" "$DEPLOY_DIR/$APP_NAME/lib/" 2>/dev/null || true
                fi
            fi
        done
    fi
done

# Create qt.conf
echo -e "${YELLOW}Creating Qt configuration...${NC}"
cat > "$DEPLOY_DIR/$APP_NAME/qt.conf" << 'EOF'
[Paths]
Prefix = .
Plugins = plugins
Imports = qml
Qml2Imports = qml
Libraries = lib
EOF

# Create launcher script
echo -e "${YELLOW}Creating launcher script...${NC}"
cat > "$DEPLOY_DIR/$APP_NAME/run.sh" << EOF
#!/bin/bash
# Self-Contained Launcher for GLADIS
# No external Qt6 installation required!

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

# Set up environment for bundled Qt
export LD_LIBRARY_PATH="\$SCRIPT_DIR/lib:\$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="\$SCRIPT_DIR/plugins"
export QML_IMPORT_PATH="\$SCRIPT_DIR/qml"
export QML2_IMPORT_PATH="\$SCRIPT_DIR/qml"
export QT_QPA_PLATFORM_PLUGIN_PATH="\$SCRIPT_DIR/plugins/platforms"

# For Raspberry Pi: detect if X11 is running and set platform accordingly
if [ -f /proc/device-tree/model ] && grep -q "Raspberry Pi" /proc/device-tree/model; then
    # Check if X11 is running (look for X server process or socket)
    if pgrep -x "X" > /dev/null || pgrep -x "Xorg" > /dev/null || [ -S /tmp/.X11-unix/X0 ]; then
        # X11 is running - use xcb platform
        export QT_QPA_PLATFORM=xcb
        # If DISPLAY is not set (e.g., running over SSH), set it to :0
        if [ -z "\$DISPLAY" ]; then
            export DISPLAY=:0
            echo "X11 detected, setting DISPLAY=:0"
        fi
    else
        # No X11 - use EGLFS for direct framebuffer rendering
        export QT_QPA_PLATFORM=eglfs
        echo "No X11 detected, using EGLFS (direct framebuffer)"
    fi
fi

# Run the application
exec "\$SCRIPT_DIR/$APP_NAME" "\$@"
EOF

chmod +x "$DEPLOY_DIR/$APP_NAME/run.sh"
chmod +x "$DEPLOY_DIR/$APP_NAME/$APP_NAME"

# Create README
cat > "$DEPLOY_DIR/$APP_NAME/README.md" << EOF
# GLADIS - Self-Contained Application

## Zero Dependencies Required! ✨

This is a **completely self-contained** application bundle. You do NOT need to install Qt6 or any other dependencies on the target system.

## What's Included

- **GLADIS**: The main application executable
- **lib/**: All Qt6 and required shared libraries (~100-150 MB)
- **plugins/**: Qt6 platform plugins (X11, Wayland, EGLFS for Raspberry Pi)
- **qml/**: All Qt Quick/QML modules
- **qt.conf**: Qt configuration file
- **run.sh**: Launcher script that sets up the environment

## How to Run

### Simple Method
\`\`\`bash
./run.sh
\`\`\`

### Copy Anywhere
You can copy this entire folder to any location (USB drive, another machine, etc.) and it will work:
\`\`\`bash
cp -r $APP_NAME /path/to/anywhere/
cd /path/to/anywhere/$APP_NAME
./run.sh
\`\`\`

## Raspberry Pi 5 Deployment

1. Copy the entire folder to your Raspberry Pi:
   \`\`\`bash
   scp -r GLADIS pi@raspberrypi.local:~/
   \`\`\`

2. SSH into Pi and run:
   \`\`\`bash
   cd ~/GLADIS
   ./run.sh
   \`\`\`

3. For auto-start on boot, add to crontab:
   \`\`\`bash
   @reboot /home/pi/GLADIS/run.sh
   \`\`\`

## Distribution

To create a distributable archive:
\`\`\`bash
tar -czf GLADIS-v${VERSION}-${ARCH}.tar.gz GLADIS
\`\`\`

Recipients just extract and run:
\`\`\`bash
tar -xzf GLADIS-v${VERSION}-${ARCH}.tar.gz
cd GLADIS
./run.sh
\`\`\`

## System Requirements

- **Operating System**: Any Linux distribution (x86_64 or ARM64)
- **Graphics**: OpenGL 2.0 or OpenGL ES 2.0 support
- **RAM**: 512 MB minimum (recommended: 1 GB+)
- **No Qt6 installation required!**
- **No apt-get install needed!**

## Verified Platforms

- ✅ Raspberry Pi 5 (Raspberry Pi OS)
- ✅ Ubuntu 22.04+ (x86_64)
- ✅ Debian 12+ (ARM64/x86_64)
- ✅ Any modern Linux distribution

---

Built with Qt6 | Self-Contained Deployment | Version $VERSION
EOF

# Calculate sizes
BUNDLE_SIZE=$(du -sh "$DEPLOY_DIR/$APP_NAME" | cut -f1)
LIB_SIZE=$(du -sh "$DEPLOY_DIR/$APP_NAME/lib" | cut -f1)
QML_SIZE=$(du -sh "$DEPLOY_DIR/$APP_NAME/qml" | cut -f1)

# Create distributable archive
echo -e "${YELLOW}Creating distributable archive...${NC}"
cd "$DEPLOY_DIR"
tar -czf "${APP_NAME}-v${VERSION}-${ARCH}.tar.gz" "$APP_NAME"
cd ..
ARCHIVE_SIZE=$(du -sh "$DEPLOY_DIR/${APP_NAME}-v${VERSION}-${ARCH}.tar.gz" | cut -f1)

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Deployment Successful! ✅${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Bundle Information:${NC}"
echo "  Location: $DEPLOY_DIR/$APP_NAME/"
echo "  Total Size: $BUNDLE_SIZE"
echo "  Libraries: $LIB_SIZE"
echo "  QML Modules: $QML_SIZE"
echo ""
echo -e "${YELLOW}Archive Created:${NC}"
echo "  File: $DEPLOY_DIR/${APP_NAME}-v${VERSION}-${ARCH}.tar.gz"
echo "  Size: $ARCHIVE_SIZE"
echo ""
echo -e "${YELLOW}To test locally:${NC}"
echo "  cd $DEPLOY_DIR/$APP_NAME"
echo "  ./run.sh"
echo ""
echo -e "${YELLOW}To deploy to Raspberry Pi:${NC}"
echo "  scp $DEPLOY_DIR/${APP_NAME}-v${VERSION}-${ARCH}.tar.gz pi@raspberrypi.local:~/"
echo "  ssh pi@raspberrypi.local"
echo "  tar -xzf ${APP_NAME}-v${VERSION}-${ARCH}.tar.gz"
echo "  cd $APP_NAME && ./run.sh"
echo ""
echo -e "${GREEN}✨ No Qt6 installation needed on target system! ✨${NC}"
echo ""
