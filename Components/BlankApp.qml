import QtQuick

Rectangle {
    id: root
    anchors.fill: parent

    // --- CONFIGURATION (Passed from ConfigManager) ---
    property bool blankState: false
    property int blankFade: 5  // Fade duration in seconds

    // Background color - solid black for blank screen
    color: "#000000"

    // Opacity animation controlled by blankState
    opacity: blankState ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation {
            duration: root.blankFade * 1000  // Convert seconds to milliseconds
            easing.type: Easing.InOutQuad
        }
    }

    // Log state changes
    onBlankStateChanged: {
        console.log("BlankApp state changed:", blankState ? "visible" : "hidden", "- fade duration:", blankFade, "seconds")
    }
}
