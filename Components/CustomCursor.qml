import QtQuick

// Custom Cursor Manager for GLADIS
// Provides custom mouse cursor images based on hover states
Item {
    id: cursorManager
    anchors.fill: parent

    // Cursor types
    enum CursorType {
        Point,   // Normal pointer
        Hover,   // Hovering over clickable element
        Field,   // Text field/input area
        Delay    // Waiting/loading state
    }

    property int cursorType: CustomCursor.CursorType.Point
    property bool enabled: true

    // Hide system cursor throughout the entire window
    Component.onCompleted: {
        // This will be handled by setting the cursor on the MouseArea
    }

    // Custom cursor image that follows the mouse
    Image {
        id: cursorImage
        width: 32
        height: 32
        visible: cursorManager.enabled
        smooth: true
        z: 10000 // Always on top

        // Position follows mouse
        x: cursorManager.mouseX
        y: cursorManager.mouseY

        // Change cursor based on type
        source: {
            var filePath = ""
            switch(cursorManager.cursorType) {
                case CustomCursor.CursorType.Hover:
                    filePath = configManager.mouseHover
                    break
                case CustomCursor.CursorType.Field:
                    filePath = configManager.mouseField
                    break
                case CustomCursor.CursorType.Delay:
                    filePath = configManager.mouseDelay
                    break
                case CustomCursor.CursorType.Point:
                default:
                    filePath = configManager.mousePoint
                    break
            }

            // Return empty string if no path configured
            if (!filePath || filePath === "") {
                return ""
            }

            // Use file: prefix for external files, qrc: for embedded resources
            if (filePath.startsWith("qrc:/") || filePath.startsWith("file:")) {
                return filePath
            } else if (filePath.startsWith("/")) {
                return "file:" + filePath
            } else {
                // Relative path - use qrc for embedded resources
                return "qrc:/" + filePath
            }
        }

        // Smooth cursor movement
        Behavior on x {
            NumberAnimation { duration: 0; easing.type: Easing.Linear }
        }
        Behavior on y {
            NumberAnimation { duration: 0; easing.type: Easing.Linear }
        }
    }

    // Mouse position properties (no MouseArea to avoid blocking events)
    property real mouseX: 0
    property real mouseY: 0

    // Mouse tracking via invisible MouseArea that doesn't block events
    MouseArea {
        id: mouseTracker
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton  // Don't accept any button clicks
        hoverEnabled: true
        preventStealing: false

        onPositionChanged: function(mouse) {
            cursorManager.mouseX = mouse.x
            cursorManager.mouseY = mouse.y
            mouse.accepted = false  // Pass event through
        }

        onPressed: function(mouse) {
            mouse.accepted = false  // Pass event through
        }

        onReleased: function(mouse) {
            mouse.accepted = false  // Pass event through
        }

        onClicked: function(mouse) {
            mouse.accepted = false  // Pass event through
        }
    }

    // Function to change cursor type from other components
    function setCursorType(type) {
        cursorManager.cursorType = type
    }
}
