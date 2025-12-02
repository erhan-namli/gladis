# Quick Start - Self-Contained Deployment

## For Erhan (Developer)

### Build and Deploy in 3 Commands

```bash
# 1. Build the application
mkdir -p build-local && cd build-local && cmake .. && make -j$(nproc) && cd ..

# 2. Create self-contained bundle
./deploy.sh

# 3. Send to client
# The file is in: deploy/GLADIS-v1.0-<arch>.tar.gz
```

That's it! Give the `.tar.gz` file to your client.

---

## For Tim (Client) - Raspberry Pi 5

### Running the App (First Time)

```bash
# 1. Extract the archive
tar -xzf GLADIS-v1.0-aarch64.tar.gz

# 2. Run the app
cd GLADIS
./run.sh
```

### Running the App (After Setup)

```bash
cd GLADIS
./run.sh
```

### What You Get

- ✅ **Zero dependencies** - No need to run `sudo apt install qt6-*`
- ✅ **Self-contained** - Everything bundled in one folder
- ✅ **Portable** - Copy to USB, other machines, etc.
- ✅ **Works immediately** - Extract and run
- ✅ **~40-60 MB compressed** - Easy to transfer
- ✅ **~120-150 MB extracted** - Includes all Qt6 libraries

### What You DON'T Need

- ❌ No `sudo apt install` commands
- ❌ No Qt6 installation
- ❌ No QML modules download
- ❌ No internet connection required to run
- ❌ No build tools or compilers

---

## Comparison: Before vs After

### Before (Dynamic Linking)
```bash
# Client has to run:
sudo apt install -y qt6-base-dev qt6-declarative-dev qml6-module-* cmake build-essential

# Then run:
./GLADIS
```

### After (Self-Contained Bundle)
```bash
# Client runs:
tar -xzf GLADIS-v1.0-aarch64.tar.gz
cd GLADIS
./run.sh
```

**No installation. No dependencies. Just run.**

---

## File Size Comparison

| Method | Size | Dependencies |
|--------|------|--------------|
| Original binary only | 600 KB | Requires Qt6 installed (~500 MB) |
| **Bundled folder** | **120-150 MB** | **Zero** ✅ |
| Compressed bundle | 40-60 MB | Zero ✅ |
| AppImage (optional) | 120-150 MB | Zero ✅ |

---

## Common Questions

**Q: Why is it bigger than the original 600KB binary?**
A: Because it includes ALL Qt6 libraries that were previously separate. Think of it like packing a lunch vs buying at a cafeteria - you're carrying everything with you.

**Q: Do I need Qt6 installed?**
A: **NO!** That's the whole point. Zero dependencies.

**Q: Can I copy it to another Raspberry Pi?**
A: Yes! Just copy the entire folder or send the `.tar.gz` file.

**Q: Does it work on other Linux systems?**
A: Yes! Works on Ubuntu, Debian, Raspberry Pi OS, etc. Just make sure the architecture matches (ARM64 for Pi 5, x86_64 for regular PCs).

**Q: How do I update the app?**
A: Erhan sends you a new `.tar.gz` file. You extract it (overwriting the old version) and run `./run.sh` again.

---

## Technical Details (For Curious Minds)

### What's in the Bundle?

```
GLADIS/
├── GLADIS          # Your app (600 KB)
├── run.sh                         # Launcher script
├── qt.conf                        # Qt configuration
├── README.md                      # Documentation
├── lib/                          # Qt6 libraries (~80 MB)
│   ├── libQt6Core.so.6
│   ├── libQt6Gui.so.6
│   ├── libQt6Quick.so.6
│   └── ... (30+ libraries)
├── plugins/                      # Qt6 plugins (~15 MB)
│   ├── platforms/                # X11, Wayland, EGLFS
│   ├── imageformats/            # PNG, JPG, SVG
│   └── iconengines/             # SVG icons
└── qml/                         # QML modules (~25 MB)
    ├── QtQuick/
    ├── QtQuick.2/
    ├── QtQuick.Controls/
    └── ... (all QML modules)
```

### How Does It Work?

The `run.sh` script sets up the environment so Qt6 can find its libraries:

```bash
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
export QT_PLUGIN_PATH="$SCRIPT_DIR/plugins"
export QML_IMPORT_PATH="$SCRIPT_DIR/qml"
```

Then it runs your application, which finds everything it needs in the local folder.

### Is This "Static Linking"?

Not exactly. This is **dynamic linking with bundled libraries**:

- **Static linking** = Everything compiled into one huge binary (100-200 MB single file)
- **This solution** = Multiple files in a folder, but self-contained (120-150 MB total)

Both achieve the same goal: **zero external dependencies**.

The bundled approach is:
- ✅ Faster to create (5 min vs 6-12 hours)
- ✅ Easier to maintain
- ✅ Better QML support
- ✅ Easier LGPL compliance

---

## Need Help?

See the detailed `DEPLOYMENT.md` file for:
- Auto-start on boot configuration
- Kiosk mode setup
- Troubleshooting
- Size optimization
- And more!

---

**Bottom Line:**
This is as close to "static linking" as you need. Your client gets a folder (or single file via AppImage) that works everywhere with zero installation. Perfect for Raspberry Pi deployment! 🎉
