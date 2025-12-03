import QtQuick
import QtQuick.Controls
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
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10 // Reduced spacing between numbers and text

            // 1. The Countdown Display
            Row {
                id: digitsRow
                Layout.alignment: Qt.AlignHCenter
                spacing: 10 // Spacing between digits

                // Helper to pad numbers (e.g. 9 -> "09")
                property string timeString: root.currentTime.toString().padStart(2, '0')

                // TENS DIGIT
                CubeDigit {
                    digitText: digitsRow.timeString.charAt(0)
                    primaryColor: root.colorMain
                    fontFamily: countdownFont.status === FontLoader.Ready ? countdownFont.name : "Arial"
                    // Bigger Size
                    width: 160
                    height: 300
                    fontSize: 280
                }

                // ONES DIGIT
                CubeDigit {
                    digitText: digitsRow.timeString.charAt(1)
                    primaryColor: root.colorMain
                    fontFamily: countdownFont.status === FontLoader.Ready ? countdownFont.name : "Arial"
                    // Bigger Size
                    width: 160
                    height: 300
                    fontSize: 280
                }
            }

            // 2. Description Text
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.timerText
                font.family: "Open Sans"
                font.pixelSize: 42 // Increased slightly
                font.bold: true
                font.letterSpacing: 2
                color: root.colorText
            }
        }

        // Animated Bits - Positioned at top right corner of countdown area
        Image {
            id: animatedBits
            width: 80
            height: 80
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 40
            anchors.topMargin: 40
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
        anchors.bottomMargin: 80
        spacing: 40

        // Button: LEFT (Need More Time)
        Rectangle {
            width: 300; height: 80
            radius: 10 // Slightly sharper corners per design
            color: root.colorMain
            border.color: root.colorMain
            border.width: 3
            visible: root.timerMenuLeft !== "" 

            Text {
                anchors.centerIn: parent
                text: root.timerMenuLeft
                font.pixelSize: 24; font.bold: true; color: root.colorText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.currentTime = root.timerMax
                    root.timerCount = true
                }
                onPressed: parent.scale = 0.95
                onReleased: parent.scale = 1.0
            }
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        // Button: MIDDLE
        Rectangle {
            width: 300; height: 80
            radius: 10
            color: "transparent"
            border.color: root.colorMain
            border.width: 3
            visible: root.timerMenuMiddle !== "" 

            Text {
                anchors.centerIn: parent
                text: root.timerMenuMiddle
                font.pixelSize: 24; font.bold: true; color: root.colorText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: console.log("Middle button clicked")
                onPressed: parent.scale = 0.95
                onReleased: parent.scale = 1.0
            }
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        // Button: RIGHT (Start Over)
        Rectangle {
            width: 300; height: 80
            radius: 10
            color: "transparent"
            border.color: root.colorMain
            border.width: 3
            visible: root.timerMenuRight !== "" 

            Text {
                anchors.centerIn: parent
                text: root.timerMenuRight
                font.pixelSize: 24; font.bold: true; color: root.colorText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.timerCount = false
                    root.currentTime = root.timerMax
                }
                onPressed: parent.scale = 0.95
                onReleased: parent.scale = 1.0
            }
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
    }

    // --- LOGIC ---
    Timer {
        id: mainTimer
        interval: 1000
        repeat: true
        running: root.timerCount && root.timerState && root.currentTime > 0
        onTriggered: {
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