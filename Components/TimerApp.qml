import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1024
    height: 600

    // --- CONFIGURATION (Matched to main.qml requirements) ---
    property int timerMax: 20
    property int currentTime: timerMax

    // "timerCount" controls if the timer is running (from INI)
    property bool timerCount: false
    // "timerState" is passed from main.qml (master visibility control)
    property bool timerState: true

    // Internal state to track if countdown is actually running
    // This allows buttons to override INI timerCount setting
    property bool isCountdownActive: timerCount 
    
    property string timerText: "FINISH SSO LOGIN"
    
    // Menu Button Labels
    property string timerMenuLeft: "NEED MORE TIME"
    property string timerMenuMiddle: ""
    property string timerMenuRight: "START OVER"

    // File paths
    property string timerAlert: configManager.timerAlert || "/dev/shm/app/timer_alert"
    property string timerReset: configManager.timerReset || "/dev/shm/app/timer_reset"
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

    // Font Loader (Fallback to Arial if file missing)
    FontLoader {
        id: countdownFont
        source: "qrc:/fonts/Countdown.ttf" 
    }

    // --- MAIN CONTENT ---
    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.topMargin: 40
        anchors.bottomMargin: 160  // Space for buttons at bottom

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15

            // 1. The Countdown Display with animated bits
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: digitsRow.width + animatedBits.width + 15
                height: digitsRow.height

                Row {
                    id: digitsRow
                    anchors.centerIn: parent
                    spacing: 8

                    // Helper to pad numbers (e.g. 9 -> "09")
                    property string timeString: root.currentTime.toString().padStart(2, '0')

                    // TENS DIGIT
                    CubeDigit {
                        digitText: digitsRow.timeString.charAt(0)
                        primaryColor: root.colorMain
                        fontFamily: countdownFont.status === FontLoader.Ready ? countdownFont.name : "Arial"
                        // Optimized for 1024x600
                        width: 120
                        height: 220
                        fontSize: 200
                    }

                    // ONES DIGIT
                    CubeDigit {
                        digitText: digitsRow.timeString.charAt(1)
                        primaryColor: root.colorMain
                        fontFamily: countdownFont.status === FontLoader.Ready ? countdownFont.name : "Arial"
                        // Optimized for 1024x600
                        width: 120
                        height: 220
                        fontSize: 200
                    }
                }

                // Animated Bits - Positioned near the countdown numbers (top right)
                Image {
                    id: animatedBits
                    width: 80
                    height: 80
                    anchors.left: digitsRow.right
                    anchors.top: digitsRow.top
                    anchors.leftMargin: 15
                    anchors.topMargin: 5
                    source: "qrc:/assets/gamelab-bits.svg"
                    fillMode: Image.PreserveAspectFit
                    visible: true

                    RotationAnimator {
                        target: animatedBits
                        from: 0; to: 360
                        duration: 2000
                        loops: Animation.Infinite
                        running: root.isCountdownActive
                    }
                }
            }

            // 2. Description Text
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.timerText
                font.family: "Open Sans"
                font.pixelSize: 32
                font.bold: true
                font.letterSpacing: 1.5
                color: root.colorText
            }
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
        anchors.rightMargin: 20 // Spacing from button
    }

    // Right Line
    Rectangle {
        height: 4
        color: root.colorMain
        anchors.left: buttonRow.right
        anchors.right: parent.right
        anchors.verticalCenter: buttonRow.verticalCenter
        anchors.leftMargin: 20 // Spacing from button
    }

    // --- BOTTOM BUTTONS ---
    Row {
        id: buttonRow
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 50
        spacing: 30

        // Button: LEFT (Need More Time)
        Rectangle {
            id: leftButton
            width: 260; height: 70
            radius: 10
            color: isHovered ? root.colorMain : "transparent"  // Fill on hover only
            border.color: root.colorMain
            border.width: 3
            visible: root.timerMenuLeft !== ""

            property bool isHovered: false
            property bool isDisabled: root.leftButtonPressed
            opacity: isDisabled ? 0.5 : 1.0

            Text {
                anchors.centerIn: parent
                text: root.timerMenuLeft
                font.pixelSize: 20; font.bold: true; color: root.colorText
            }

            MouseArea {
                id: leftMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor  // Hide cursor when custom cursor is enabled
                enabled: !leftButton.isDisabled

                onEntered: leftButton.isHovered = true
                onExited: leftButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    // Handle the action on release to support both mouse and touch
                    if (contains(Qt.point(mouseX, mouseY)) && !leftButton.isDisabled) {
                        root.currentTime = root.timerMax
                        root.isCountdownActive = true

                        // Create button press file
                        var buttonFile = root.buttonDir + "button_" + root.timerMenuLeft.replace(/\s+/g, "_")
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
            color: "transparent"
            border.color: root.colorMain
            border.width: 3
            visible: root.timerMenuMiddle !== ""

            property bool isHovered: false
            property bool isDisabled: root.middleButtonPressed
            opacity: isDisabled ? 0.5 : (isHovered ? 0.7 : 1.0)

            Text {
                anchors.centerIn: parent
                text: root.timerMenuMiddle
                font.pixelSize: 20; font.bold: true; color: root.colorText
            }

            MouseArea {
                id: middleMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor  // Hide cursor when custom cursor is enabled
                enabled: !middleButton.isDisabled

                onEntered: middleButton.isHovered = true
                onExited: middleButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    // Handle the action on release to support both mouse and touch
                    if (contains(Qt.point(mouseX, mouseY)) && !middleButton.isDisabled) {
                        console.log("Middle button clicked")

                        // Create button press file
                        var buttonFile = root.buttonDir + "button_" + root.timerMenuMiddle.replace(/\s+/g, "_")
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

        // Button: RIGHT (Start Over)
        Rectangle {
            id: rightButton
            width: 260; height: 70
            radius: 10
            color: "transparent"
            border.color: root.colorMain
            border.width: 3
            visible: root.timerMenuRight !== ""

            property bool isHovered: false
            property bool isDisabled: root.rightButtonPressed
            opacity: isDisabled ? 0.5 : (isHovered ? 0.7 : 1.0)

            Text {
                anchors.centerIn: parent
                text: root.timerMenuRight
                font.pixelSize: 20; font.bold: true; color: root.colorText
            }

            MouseArea {
                id: rightMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor  // Hide cursor when custom cursor is enabled
                enabled: !rightButton.isDisabled

                onEntered: rightButton.isHovered = true
                onExited: rightButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    // Handle the action on release to support both mouse and touch
                    if (contains(Qt.point(mouseX, mouseY)) && !rightButton.isDisabled) {
                        root.currentTime = root.timerMax
                        // Keep the timer running if it was already running

                        // Create button press file
                        var buttonFile = root.buttonDir + "button_" + root.timerMenuRight.replace(/\s+/g, "_")
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

    // --- LOGIC ---
    // High-precision timer that accounts for animation time
    Timer {
        id: mainTimer
        interval: 1000
        repeat: true
        // Only run timer when the app is visible AND countdown is active
        running: root.visible && root.isCountdownActive && root.timerState && root.currentTime > 0
        triggeredOnStart: false

        property real lastTickTime: 0
        property real drift: 0

        onRunningChanged: {
            if (running) {
                // Reset drift tracking when timer starts
                lastTickTime = Date.now()
                drift = 0
            }
        }

        onTriggered: {
            // Calculate actual time elapsed since last tick
            var currentTime = Date.now()
            var elapsed = currentTime - lastTickTime

            // Accumulate drift (difference from expected 1000ms)
            drift += (elapsed - 1000)

            // Adjust next interval to compensate for drift
            // If we're running slow (drift > 0), decrease interval
            // If we're running fast (drift < 0), increase interval
            var adjustedInterval = 1000 - drift

            // Clamp adjustment to reasonable bounds (900-1100ms)
            adjustedInterval = Math.max(900, Math.min(1100, adjustedInterval))
            interval = Math.round(adjustedInterval)

            // Update last tick time
            lastTickTime = currentTime

            // Reset drift after adjustment
            drift = 0

            // Decrement counter
            root.currentTime--
            if (root.currentTime === 0) {
                console.log("Timer Finished")
                // Write alert file
                writeTimerAlertFile()
            }
        }
    }

    // Watch for timer reset file and button files
    Connections {
        target: fileIO

        function onFileChanged(path) {
            if (path === root.timerReset) {
                console.log("Timer reset file detected")
                root.currentTime = root.timerMax
                root.isCountdownActive = false

                // Delete the reset file
                fileIO.deleteFile(root.timerReset)
            }

            // Check for button file deletions (file no longer exists = re-enable button)
            var leftButtonFile = root.buttonDir + "button_" + root.timerMenuLeft.replace(/\s+/g, "_")
            var middleButtonFile = root.buttonDir + "button_" + root.timerMenuMiddle.replace(/\s+/g, "_")
            var rightButtonFile = root.buttonDir + "button_" + root.timerMenuRight.replace(/\s+/g, "_")

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

    Component.onCompleted: {
        // Start watching for timer reset file
        fileIO.watchFile(root.timerReset)
    }

    // Helper function to write timer alert file
    function writeTimerAlertFile() {
        console.log("Timer expired - writing alert file:", root.timerAlert)
        fileIO.writeFile(root.timerAlert, "1")
    }
    
    // Sync isCountdownActive with timerCount from INI
    onTimerCountChanged: {
        root.isCountdownActive = root.timerCount
    }

    onTimerMaxChanged: {
        if (!root.isCountdownActive) {
            root.currentTime = root.timerMax
        }
    }

    // ---------------------------------------------------------
    //  INTERNAL COMPONENT: CUBE DIGIT
    // ---------------------------------------------------------
    component CubeDigit : Item {
        id: cubeComp
        // Default size (can be overridden)
        width: 120
        height: 240
        clip: true 

        // API
        property string digitText: "0"
        property color primaryColor: "#FFFFFF"
        property string fontFamily: "Arial"
        property int animDuration: 200
        property int fontSize: 200 // Added property for font size control

        // The text currently visible (Old)
        Text {
            id: currentFace
            anchors.centerIn: parent
            text: cubeComp.digitText 
            font.family: cubeComp.fontFamily
            font.pixelSize: cubeComp.fontSize
            color: cubeComp.primaryColor
            
            transform: Rotation {
                id: currentRot
                origin.x: currentFace.width / 2
                origin.y: currentFace.height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: 0
            }
        }

        // The text waiting to animate in (New)
        Text {
            id: nextFace
            anchors.centerIn: parent
            text: "" 
            font.family: cubeComp.fontFamily
            font.pixelSize: cubeComp.fontSize
            color: cubeComp.primaryColor
            opacity: 0

            transform: Rotation {
                id: nextRot
                origin.x: nextFace.width / 2
                origin.y: nextFace.height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: -90 
            }
        }

        // Detect Change -> Animate
        onDigitTextChanged: {
            nextFace.text = digitText
            if (cubeAnim.running) {
                cubeAnim.stop()
                finalizeState()
            }
            cubeAnim.start()
        }

        function finalizeState() {
            currentFace.text = nextFace.text
            currentFace.opacity = 1
            currentRot.angle = 0
            
            nextFace.opacity = 0
            nextRot.angle = -90
        }

        ParallelAnimation {
            id: cubeAnim
            
            NumberAnimation { 
                target: currentRot; property: "angle"
                to: 90; duration: cubeComp.animDuration; easing.type: Easing.InOutQuad 
            }
            NumberAnimation { 
                target: currentFace; property: "opacity"
                to: 0; duration: cubeComp.animDuration; easing.type: Easing.InOutQuad 
            }

            NumberAnimation { 
                target: nextRot; property: "angle"
                from: -90; to: 0; duration: cubeComp.animDuration; easing.type: Easing.InOutQuad 
            }
            NumberAnimation { 
                target: nextFace; property: "opacity"
                from: 0; to: 1; duration: cubeComp.animDuration; easing.type: Easing.InOutQuad 
            }

            onFinished: cubeComp.finalizeState()
        }
    }
}