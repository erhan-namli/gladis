import QtQuick
import QtQuick.Controls

// Image App (app_image) - Display full-screen image (ads, announcements, etc.)
// Can be loaded on any layer
Item {
    id: root
    anchors.fill: parent

    // Configuration properties
    property string imagePath: configManager.imageSource || ""
    property string backgroundColor: configManager.imageBgColor || "#000000"
    property int fillMode: configManager.imageFillMode || Image.PreserveAspectFit
    property bool showBackground: configManager.imageShowBg || false

    // Helper to check if file is GIF
    function isGifFile(path) {
        return path.toLowerCase().endsWith('.gif')
    }

    // Background (optional - can be transparent to show layers below)
    Rectangle {
        anchors.fill: parent
        color: root.showBackground ? root.backgroundColor : "transparent"
        z: -1  // Behind image
    }

    // Current visible static image
    Image {
        id: mainImage
        // For mode 0 (centered, no scaling), don't fill parent
        anchors.centerIn: root.fillMode === 0 ? parent : undefined
        anchors.fill: root.fillMode === 0 ? undefined : parent
        source: !isGifFile(root.imagePath) && root.imagePath ? (root.imagePath.startsWith("file:") || root.imagePath.startsWith("qrc:/") ? root.imagePath : "file:" + root.imagePath) : ""
        // fillMode mapping: 0=Pad (centered no scale), 1=PreserveAspectFit, 2=PreserveAspectCrop, 3=Stretch
        fillMode: root.fillMode === 0 ? Image.Pad : root.fillMode
        smooth: true
        asynchronous: true
        cache: false  // Don't cache so images update when INI changes
        opacity: 1.0
        z: 1  // On top of preloader
        visible: !isGifFile(root.imagePath)

        // Center the image if using PreserveAspectFit or PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        onStatusChanged: {
            if (status === Image.Error) {
                console.error("ImageApp: Failed to load image:", root.imagePath)
            } else if (status === Image.Ready) {
                console.log("ImageApp: Image loaded successfully:", root.imagePath)
            }
        }
    }

    // Animated GIF support
    AnimatedImage {
        id: mainAnimatedImage
        // For mode 0 (centered, no scaling), don't fill parent
        anchors.centerIn: root.fillMode === 0 ? parent : undefined
        anchors.fill: root.fillMode === 0 ? undefined : parent
        source: isGifFile(root.imagePath) && root.imagePath ? (root.imagePath.startsWith("file:") || root.imagePath.startsWith("qrc:/") ? root.imagePath : "file:" + root.imagePath) : ""
        // fillMode mapping: 0=Pad (centered no scale), 1=PreserveAspectFit, 2=PreserveAspectCrop, 3=Stretch
        fillMode: root.fillMode === 0 ? Image.Pad : root.fillMode
        smooth: true
        asynchronous: true
        cache: false
        opacity: 1.0
        z: 1
        visible: isGifFile(root.imagePath)
        playing: true  // Auto-play GIFs

        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        onStatusChanged: {
            if (status === AnimatedImage.Error) {
                console.error("ImageApp: Failed to load animated image:", root.imagePath)
            } else if (status === AnimatedImage.Ready) {
                console.log("ImageApp: Animated image loaded successfully:", root.imagePath)
            }
        }
    }

    // Preloader image for seamless transitions
    Image {
        id: preloaderImage
        anchors.centerIn: root.fillMode === 0 ? parent : undefined
        anchors.fill: root.fillMode === 0 ? undefined : parent
        fillMode: root.fillMode === 0 ? Image.Pad : root.fillMode
        smooth: true
        asynchronous: true
        cache: false
        opacity: 0.0
        z: 0  // Behind main image
        visible: false

        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        onStatusChanged: {
            if (status === Image.Ready) {
                // New image loaded, now swap
                visible = true
                opacity = 1.0
                mainImage.opacity = 0.0
            }
        }
    }

    // Loading indicator (only show when first loading, not during transitions)
    BusyIndicator {
        anchors.centerIn: parent
        running: mainImage.status === Image.Loading && mainImage.source === ""
        visible: running
        width: 64
        height: 64
        z: 2
    }

    // Error message display
    Rectangle {
        anchors.fill: parent
        color: root.showBackground ? root.backgroundColor : "#1a1a1a"
        visible: (mainImage.status === Image.Error || mainAnimatedImage.status === AnimatedImage.Error) && root.imagePath !== ""
        z: 1

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "⚠"
                font.pixelSize: 72
                color: "#ff6b6b"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Failed to load image"
                font.pixelSize: 24
                font.family: "Open Sans"
                font.weight: Font.Bold
                color: "#ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: root.imagePath
                font.pixelSize: 16
                font.family: "Open Sans"
                color: "#999999"
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(implicitWidth, root.width * 0.8)
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // Watch for config changes
    Connections {
        target: configManager

        function onConfigChanged() {
            console.log("ImageApp: Config changed, reloading image...")
            console.log("  Image path:", root.imagePath)
            console.log("  Fill mode:", root.fillMode)
            console.log("  Background:", root.showBackground, root.backgroundColor)

            // Seamless image swap: load new image in preloader first
            var newSource = root.imagePath ? (root.imagePath.startsWith("file:") || root.imagePath.startsWith("qrc:/") ? root.imagePath : "file:" + root.imagePath) : ""

            // Don't use preloader for GIFs (AnimatedImage handles it)
            if (!isGifFile(root.imagePath)) {
                if (newSource !== mainImage.source && newSource !== "") {
                    // Start loading new image in background
                    preloaderImage.source = newSource
                } else if (newSource === "") {
                    // If clearing image, just fade out
                    mainImage.opacity = 0.0
                }
            }
        }
    }

    // Handle preloader -> main swap completion
    Connections {
        target: preloaderImage

        function onOpacityChanged() {
            if (preloaderImage.opacity === 1.0 && mainImage.opacity === 0.0) {
                // Swap complete, move preloader content to main
                Qt.callLater(function() {
                    mainImage.source = preloaderImage.source
                    mainImage.opacity = 1.0
                    preloaderImage.opacity = 0.0
                    preloaderImage.visible = false
                    preloaderImage.source = ""
                })
            }
        }
    }

    Component.onCompleted: {
        console.log("ImageApp initialized")
        console.log("  Image path:", root.imagePath)
        console.log("  Fill mode:", root.fillMode)
        console.log("  Background:", root.showBackground ? root.backgroundColor : "transparent")
    }
}
