import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1024
    height: 600

    // --- CONFIGURATION (Matched to main.qml requirements) ---
    property int timerMax: 20
    property int currentTime: timerMax
    
    // "timerCount" controls if the timer is running
    property bool timerCount: false 
    // "timerState" is passed from main.qml
    property bool timerState: true 
    
    property string timerText: "FINISH SSO LOGIN"
    
    // Menu Button Labels
    property string timerMenuLeft: "NEED MORE TIME"
    property string timerMenuMiddle: ""
    property string timerMenuRight: "START OVER"

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
                        running: root.timerCount
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
            color: root.colorMain
            border.color: root.colorMain
            border.width: 3
            visible: root.timerMenuLeft !== ""

            property bool isHovered: false
            opacity: isHovered ? 0.7 : 1.0

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

                onEntered: leftButton.isHovered = true
                onExited: leftButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    // Handle the action on release to support both mouse and touch
                    if (contains(Qt.point(mouseX, mouseY))) {
                        root.currentTime = root.timerMax
                        root.timerCount = true
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
            opacity: isHovered ? 0.7 : 1.0

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

                onEntered: middleButton.isHovered = true
                onExited: middleButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    // Handle the action on release to support both mouse and touch
                    if (contains(Qt.point(mouseX, mouseY))) {
                        console.log("Middle button clicked")
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
            opacity: isHovered ? 0.7 : 1.0

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

                onEntered: rightButton.isHovered = true
                onExited: rightButton.isHovered = false

                onPressed: parent.scale = 0.95

                onReleased: {
                    parent.scale = 1.0
                    // Handle the action on release to support both mouse and touch
                    if (contains(Qt.point(mouseX, mouseY))) {
                        root.currentTime = root.timerMax
                        // Keep the timer running if it was already running
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
        // Only run timer when the app is visible AND timer settings allow it
        running: root.visible && root.timerCount && root.timerState && root.currentTime > 0
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
            }
        }
    }
    
    onTimerMaxChanged: {
        if (!root.timerCount) {
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