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

    // Background (optional - can be transparent to show layers below)
    Rectangle {
        anchors.fill: parent
        color: root.showBackground ? root.backgroundColor : "transparent"
        z: -1  // Behind image
    }

    // Main image
    Image {
        id: mainImage
        anchors.fill: parent
        source: root.imagePath ? (root.imagePath.startsWith("file:") || root.imagePath.startsWith("qrc:/") ? root.imagePath : "file:" + root.imagePath) : ""
        fillMode: root.fillMode
        smooth: true
        asynchronous: true
        cache: false  // Don't cache so images update when INI changes

        // Show loading indicator or placeholder
        visible: status === Image.Ready || status === Image.Loading

        // Center the image if using PreserveAspectFit or PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        onStatusChanged: {
            if (status === Image.Error) {
                console.error("ImageApp: Failed to load image:", root.imagePath)
            } else if (status === Image.Ready) {
                console.log("ImageApp: Image loaded successfully:", root.imagePath)
            }
        }
    }

    // Loading indicator (optional)
    BusyIndicator {
        anchors.centerIn: parent
        running: mainImage.status === Image.Loading
        visible: running
        width: 64
        height: 64
    }

    // Error message display
    Rectangle {
        anchors.fill: parent
        color: root.showBackground ? root.backgroundColor : "#1a1a1a"
        visible: mainImage.status === Image.Error && root.imagePath !== ""
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

            // Force image reload
            var oldSource = mainImage.source
            mainImage.source = ""
            Qt.callLater(function() {
                mainImage.source = root.imagePath ? (root.imagePath.startsWith("file:") || root.imagePath.startsWith("qrc:/") ? root.imagePath : "file:" + root.imagePath) : ""
            })
        }
    }

    Component.onCompleted: {
        console.log("ImageApp initialized")
        console.log("  Image path:", root.imagePath)
        console.log("  Fill mode:", root.fillMode)
        console.log("  Background:", root.showBackground ? root.backgroundColor : "transparent")
    }
}
