# PixmapScrollingText Usage Guide

## Overview
`PixmapScrollingText.qml` is a performance-optimized scrolling text component designed for Raspberry Pi 5 and other resource-constrained devices. It renders text to a pixmap (texture) once and animates that texture, providing smoother performance than animating text directly.

**NEW:** Includes GPU-based directional motion blur to eliminate perceived stutter and create ultra-smooth scrolling!

## How to Switch from ScrollingText to PixmapScrollingText

### Current Implementation (Fade In/Out Carousel)
In `main.qml`, you currently use:

```qml
ScrollingText {
    id: topScroll
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 60
    text: dataManager.scrollUpperText
    textColor: mainWindow.hoverColor
    backgroundColor: "#1a1a1a"
    textSize: 40
    showBottomLine: true
    scrollSpeed: 150
}
```

### Switching to Pixmap Scrolling (Horizontal Scroll)

Simply change the component name from `ScrollingText` to `PixmapScrollingText`:

```qml
PixmapScrollingText {
    id: topScroll
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 60
    text: dataManager.scrollUpperText
    textColor: mainWindow.hoverColor
    backgroundColor: "#1a1a1a"
    textSize: 40
    showBottomLine: true
    scrollSpeed: 150  // Now controls pixels per second of horizontal scrolling
}
```

That's it! The API is compatible.

## Key Differences

### ScrollingText (Current - Fade In/Out)
- ✅ Fades text in, displays, then fades out
- ✅ Cycles through text parts if text is too long
- ✅ Good for short text snippets
- ❌ Can be choppy on Pi5

### PixmapScrollingText (New - Horizontal Scroll)
- ✅ Smooth horizontal scrolling
- ✅ Better performance on Pi5 (hardware accelerated)
- ✅ Text is rendered once as a pixmap/texture
- ✅ Infinite seamless loop
- ⚠️ Shows entire text continuously scrolling (doesn't break into parts)

## Configuration Options

Both components share these common properties:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `text` | string | "" | Text to display |
| `textColor` | color | "#00D9FF" | Text color |
| `backgroundColor` | color | "#1a1a1a" | Background color |
| `textSize` | int | 40 | Font size in pixels |
| `scrollSpeed` | real | 100 | Pixels per second (PixmapScrollingText) or legacy value (ScrollingText) |
| `showTopLine` | bool | false | Show blue line at top |
| `showBottomLine` | bool | false | Show blue line at bottom |

Additional properties for `PixmapScrollingText`:

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `textSpacing` | int | 100 | Space between repeated text instances (pixels) |
| `enableMotionBlur` | bool | false | Enable GPU-based horizontal motion blur (experimental) |
| `motionBlurRadius` | int | 4 | Blur radius in pixels (3-6 recommended) |
| `motionBlurSamples` | int | 8 | Blur quality samples (higher = smoother) |

### Motion Blur Feature (NEW - EXPERIMENTAL)
Motion blur is **disabled by default** and provides a cinematic effect that eliminates perceived stutter during scrolling. The blur is:
- **GPU-accelerated** (applied to already-rendered textures, not recalculated per frame)
- **Horizontal directional** (matches scroll direction)
- **Low CPU overhead** (perfect for Raspberry Pi 5)
- **Configurable** (adjust radius and samples for visual preference)

To enable motion blur (test first on your device):
```qml
PixmapScrollingText {
    enableMotionBlur: true   // Enable for smoother perceived motion
    motionBlurRadius: 4      // Adjust blur amount (3-6 recommended)
}
```

To fine-tune motion blur after enabling:
```qml
PixmapScrollingText {
    motionBlurRadius: 6        // Increase for more blur (3-6 recommended)
    motionBlurSamples: 12      // Increase for smoother blur (8-16 range)
}
```

## Example: Complete Replacement in main.qml

### Option 1: Replace Both Scrolling Texts

```qml
// Top scrolling banner
PixmapScrollingText {
    id: topScroll
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 60
    text: dataManager.scrollUpperText
    textColor: mainWindow.hoverColor
    backgroundColor: "#1a1a1a"
    textSize: 40
    showBottomLine: true
    scrollSpeed: 100  // Adjust for desired speed
    textSpacing: 150   // Space between text repeats
}

// Bottom scrolling banner
PixmapScrollingText {
    id: bottomScroll
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: 60
    text: dataManager.scrollLowerText
    textColor: mainWindow.hoverColor
    backgroundColor: "#1a1a1a"
    textSize: 40
    showTopLine: true
    scrollSpeed: 100
    textSpacing: 150
}
```

### Option 2: Easy Toggle Between Implementations

Create a property at the top of `main.qml` to easily switch:

```qml
Window {
    id: mainWindow

    // Toggle between scrolling implementations
    readonly property bool usePixmapScrolling: true  // Set to false to use fade in/out

    // ... rest of code ...

    Loader {
        id: topScroll
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60

        sourceComponent: mainWindow.usePixmapScrolling ? pixmapScrollComponent : fadeScrollComponent

        property string scrollText: dataManager.scrollUpperText
    }

    Component {
        id: pixmapScrollComponent
        PixmapScrollingText {
            text: topScroll.scrollText
            textColor: mainWindow.hoverColor
            backgroundColor: "#1a1a1a"
            textSize: 40
            showBottomLine: true
            scrollSpeed: 100
            textSpacing: 150
        }
    }

    Component {
        id: fadeScrollComponent
        ScrollingText {
            text: topScroll.scrollText
            textColor: mainWindow.hoverColor
            backgroundColor: "#1a1a1a"
            textSize: 40
            showBottomLine: true
            scrollSpeed: 150
        }
    }
}
```

## Performance Tips

1. **Adjust scrollSpeed**: Lower values = slower, smoother. Higher values = faster. Try 80-120 for smooth scrolling.
2. **Adjust textSpacing**: 100-200 pixels recommended for good visual separation.
3. **Font rendering**: The component uses `Text.NativeRendering` for better pixmap quality.
4. **Hardware acceleration**: The ShaderEffectSource provides hardware-accelerated rendering.

## Troubleshooting

### Text not appearing
- Check that `text` property is set and not empty
- Verify `textColor` is different from `backgroundColor`
- Check console logs for text width and animation duration

### Choppy animation
- Reduce `scrollSpeed` value
- Ensure Pi5 is not thermal throttling
- Check GPU memory allocation in Pi5 config

### Text looks blurry
- Try adjusting `textSize` to a slightly larger/smaller value
- Check Pi5 display resolution settings

## Technical Details

The component works by:
1. Rendering a Text element to a hidden container
2. Using `ShaderEffectSource` to capture it as a GPU texture/pixmap
3. Creating 3 instances of this texture in a Row
4. Animating the Row's x position with linear easing
5. Resetting position when one instance scrolls off-screen for seamless loop

This provides hardware-accelerated, smooth scrolling performance on the Raspberry Pi 5.
