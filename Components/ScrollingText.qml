import QtQuick

Rectangle {
    id: root

    property string text: "SEAMLESS SCROLLING TEXT NOTIFICATION"
    property color textColor: "#ffffff"
    property color backgroundColor: "#1a1a1a"
    property int textSize: 40
    property int scrollSpeed: 100 // Not used for fading, kept for compatibility
    property bool showTopLine: false
    property bool showBottomLine: false

    // Fading carousel properties
    property int fadeInDuration: 800      // milliseconds
    property int displayDuration: 3000    // How long text stays visible
    property int fadeOutDuration: 800     // milliseconds

    height: 60
    color: backgroundColor
    clip: true

    // Blue line at top (only if showTopLine is true)
    Rectangle {
        visible: root.showTopLine
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        color: "#00AEEF"
    }

    // Blue line at bottom (only if showBottomLine is true)
    Rectangle {
        visible: root.showBottomLine
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        color: "#00AEEF"
    }

    // Fading text display with multi-part support
    Item {
        id: textContainer
        anchors.fill: parent
        anchors.topMargin: root.showTopLine ? 6 : 0
        anchors.bottomMargin: root.showBottomLine ? 6 : 0

        property var textParts: []
        property int currentIndex: 0

        // Hidden text for measuring
        Text {
            id: measureText
            visible: false
            font.pixelSize: root.textSize
            font.family: "Open Sans"
            font.bold: true
        }

        Text {
            id: displayText
            anchors.centerIn: parent
            text: textContainer.textParts.length > 0 ? textContainer.textParts[textContainer.currentIndex] : root.text
            font.pixelSize: root.textSize
            font.family: "Open Sans"
            font.bold: true
            color: root.textColor
            opacity: 0

            SequentialAnimation {
                id: fadeAnimation
                running: false
                // No loops - we manually restart in onStopped to cycle through parts

                // Fade in
                NumberAnimation {
                    target: displayText
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.fadeInDuration
                    easing.type: Easing.InOutQuad
                }

                // Stay visible
                PauseAnimation {
                    duration: root.displayDuration
                }

                // Fade out
                NumberAnimation {
                    target: displayText
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: root.fadeOutDuration
                    easing.type: Easing.InOutQuad
                }

                // Brief pause before next cycle
                PauseAnimation {
                    duration: 500
                }

                onStopped: {
                    // Move to next text part
                    if (textContainer.textParts.length > 1) {
                        textContainer.currentIndex = (textContainer.currentIndex + 1) % textContainer.textParts.length
                    }
                    // Restart animation for next part
                    fadeAnimation.start()
                }
            }
        }

        Component.onCompleted: {
            // Wait a moment for layout to complete before measuring
            Qt.callLater(function() {
                splitTextIfNeeded()
                fadeAnimation.start()
            })
        }

        // Re-split when container width changes
        onWidthChanged: {
            if (width > 0) {
                Qt.callLater(splitTextIfNeeded)
            }
        }

        // Watch for text changes
        Connections {
            target: root
            function onTextChanged() {
                textContainer.splitTextIfNeeded()
            }
        }

        function splitTextIfNeeded() {
            if (!root.text || root.text.length === 0) {
                textContainer.textParts = [""]
                textContainer.currentIndex = 0
                return
            }

            // Don't split if width isn't ready yet
            if (textContainer.width <= 0) {
                console.log("Width not ready yet, skipping split")
                return
            }

            measureText.text = root.text
            var availableWidth = textContainer.width - 40 // 20px padding on each side

            console.log("Splitting text. Container width:", textContainer.width, "Available width:", availableWidth, "Text width:", measureText.width)

            // If text fits, use it as-is
            if (measureText.width <= availableWidth) {
                console.log("Text fits on one line")
                textContainer.textParts = [root.text]
                textContainer.currentIndex = 0
                return
            }

            // Text is too long, split it into parts
            var words = root.text.split(' ')
            var parts = []
            var currentPart = ""

            for (var i = 0; i < words.length; i++) {
                var testPart = currentPart ? currentPart + " " + words[i] : words[i]
                measureText.text = testPart

                if (measureText.width > availableWidth && currentPart !== "") {
                    // Current part is full, save it and start new part
                    parts.push(currentPart)
                    currentPart = words[i]
                } else {
                    currentPart = testPart
                }
            }

            // Add the last part
            if (currentPart) {
                parts.push(currentPart)
            }

            textContainer.textParts = parts.length > 0 ? parts : [root.text]
            textContainer.currentIndex = 0

            console.log("Split into", textContainer.textParts.length, "parts:")
            for (var j = 0; j < textContainer.textParts.length; j++) {
                console.log("  Part", j + ":", textContainer.textParts[j])
            }
        }
    }
}
