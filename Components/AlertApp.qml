import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1024
    height: 600

    // --- CONFIGURATION (Passed from ConfigManager) ---
    property bool alertState: true
    property string alertText: "WANT TO CONTINUE?"

    // Menu Button Labels
    property string alertMenuLeft: "YES"
    property string alertMenuMiddle: ""
    property string alertMenuRight: "NO!"

    // File paths
    property string buttonDir: configManager.buttonDir || "/dev/shm/app/"

    // Button press state tracking
    property bool leftButtonPressed: false
    property bool middleButtonPressed: false
    property bool rightButtonPressed: false

    // --- THEME ---
    property color colorMain: "#FF6B35"
    property color colorBg01: "#1e3a5f"
    property color colorBg02: "#2a5080"
    property color colorText: "#FFFFFF"

    // Background Gradient
    gradient: Gradient {
        GradientStop { position: 0.0; color: root.colorBg01 }
        GradientStop { position: 1.0; color: root.colorBg02 }
    }

    // --- MAIN CONTENT ---
    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.topMargin: 40
        anchors.bottomMargin: 160  // Space for buttons at bottom

        // Alert Text - centered, max width 640px, double size of timer text
        Text {
            id: alertTextElement
            anchors.horizontalCenter: parent.horizontalCenter
            // Align top with where timer numbers would be (estimated based on TimerApp layout)
            anchors.top: parent.top
            anchors.topMargin: 80

            width: Math.min(640, parent.width - 40)

            text: root.alertText
            font.family: "Open Sans"
            font.pixelSize: 64  // Double the timer text size (32 * 2)
            font.bold: true
            font.letterSpacing: 1.5
            color: root.colorText

            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    // --- DECORATIVE LINES ---
    // Left Line
    Rectangle {
        height: 4
        color: root.colorMain
        anchors.left: parent.left
        anchors.right: buttonRow.left
        anchors.verticalCenter: buttonRow.verticalCenter
        anchors.rightMargin: 20
    }

    // Right Line
    Rectangle {
        height: 4
        color: root.colorMain
        anchors.left: buttonRow.right
        anchors.right: parent.right
        anchors.verticalCenter: buttonRow.verticalCenter
        anchors.leftMargin: 20
    }

    // --- BOTTOM BUTTONS (Same as TimerApp) ---
    Row {
        id: buttonRow
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 50
        spacing: 30

        // Button: LEFT
        Rectangle {
            id: leftButton
            width: 260; height: 70
            radius: 10
            color: isHovered ? root.colorMain : "transparent"  // Fill on hover only
            border.color: root.colorMain
            border.width: 3
            visible: root.alertMenuLeft !== ""

            property bool isHovered: false
            property bool isDisabled: root.leftButtonPressed
            opacity: isDisabled ? 0.5 : 1.0

            Text {
                anchors.centerIn: parent
                text: root.alertMenuLeft
                font.pixelSize: 20; font.bold: true; color: root.colorText
            }

            MouseArea {
                id: leftMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor
                enabled: !leftButton.isDisabled

                onEntered: leftButton.isHovered = true
                onExited: leftButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    if (contains(Qt.point(mouseX, mouseY)) && !leftButton.isDisabled) {
                        console.log("Alert: Left button clicked -", root.alertMenuLeft)

                        // Create button press file
                        var buttonFile = root.buttonDir + "button_" + root.alertMenuLeft.replace(/\s+/g, "_")
                        fileIO.writeFile(buttonFile, "1")
                        root.leftButtonPressed = true
                        fileIO.watchFile(buttonFile)
                        console.log("Button pressed, created file:", buttonFile)
                    }
                }

                onCanceled: {
                    parent.scale = 1.0
                }
            }

            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // Button: MIDDLE
        Rectangle {
            id: middleButton
            width: 260; height: 70
            radius: 10
            color: isHovered ? root.colorMain : "transparent"  // Fill on hover only
            border.color: root.colorMain
            border.width: 3
            visible: root.alertMenuMiddle !== ""

            property bool isHovered: false
            property bool isDisabled: root.middleButtonPressed
            opacity: isDisabled ? 0.5 : 1.0

            Text {
                anchors.centerIn: parent
                text: root.alertMenuMiddle
                font.pixelSize: 20; font.bold: true; color: root.colorText
            }

            MouseArea {
                id: middleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor
                enabled: !middleButton.isDisabled

                onEntered: middleButton.isHovered = true
                onExited: middleButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    if (contains(Qt.point(mouseX, mouseY)) && !middleButton.isDisabled) {
                        console.log("Alert: Middle button clicked -", root.alertMenuMiddle)

                        // Create button press file
                        var buttonFile = root.buttonDir + "button_" + root.alertMenuMiddle.replace(/\s+/g, "_")
                        fileIO.writeFile(buttonFile, "1")
                        root.middleButtonPressed = true
                        fileIO.watchFile(buttonFile)
                        console.log("Button pressed, created file:", buttonFile)
                    }
                }

                onCanceled: {
                    parent.scale = 1.0
                }
            }

            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        // Button: RIGHT
        Rectangle {
            id: rightButton
            width: 260; height: 70
            radius: 10
            color: isHovered ? root.colorMain : "transparent"  // Fill on hover only
            border.color: root.colorMain
            border.width: 3
            visible: root.alertMenuRight !== ""

            property bool isHovered: false
            property bool isDisabled: root.rightButtonPressed
            opacity: isDisabled ? 0.5 : 1.0

            Text {
                anchors.centerIn: parent
                text: root.alertMenuRight
                font.pixelSize: 20; font.bold: true; color: root.colorText
            }

            MouseArea {
                id: rightMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor
                enabled: !rightButton.isDisabled

                onEntered: rightButton.isHovered = true
                onExited: rightButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    if (contains(Qt.point(mouseX, mouseY)) && !rightButton.isDisabled) {
                        console.log("Alert: Right button clicked -", root.alertMenuRight)

                        // Create button press file
                        var buttonFile = root.buttonDir + "button_" + root.alertMenuRight.replace(/\s+/g, "_")
                        fileIO.writeFile(buttonFile, "1")
                        root.rightButtonPressed = true
                        fileIO.watchFile(buttonFile)
                        console.log("Button pressed, created file:", buttonFile)
                    }
                }

                onCanceled: {
                    parent.scale = 1.0
                }
            }

            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    // Watch for button files
    Connections {
        target: fileIO

        function onFileChanged(path) {
            // Check for button file deletions (file no longer exists = re-enable button)
            var leftButtonFile = root.buttonDir + "button_" + root.alertMenuLeft.replace(/\s+/g, "_")
            var middleButtonFile = root.buttonDir + "button_" + root.alertMenuMiddle.replace(/\s+/g, "_")
            var rightButtonFile = root.buttonDir + "button_" + root.alertMenuRight.replace(/\s+/g, "_")

            if (path === leftButtonFile && !fileIO.fileExists(leftButtonFile)) {
                console.log("Left button file deleted, re-enabling button")
                root.leftButtonPressed = false
            }
            if (path === middleButtonFile && !fileIO.fileExists(middleButtonFile)) {
                console.log("Middle button file deleted, re-enabling button")
                root.middleButtonPressed = false
            }
            if (path === rightButtonFile && !fileIO.fileExists(rightButtonFile)) {
                console.log("Right button file deleted, re-enabling button")
                root.rightButtonPressed = false
            }
        }
    }
}
