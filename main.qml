import QtQuick
import QtQuick.Window
import "Components"

Window {
    id: mainWindow
    visible: true
    // Visibility controlled by render_screen setting in INI
    visibility: configManager.renderScreen === 1 ? Window.FullScreen : Window.Windowed
    // Resolution from config - swap width/height for 90/270 degree rotations
    width: (configManager.renderRotate === 90 || configManager.renderRotate === 270) ? configManager.renderHeight : configManager.renderWidth
    height: (configManager.renderRotate === 90 || configManager.renderRotate === 270) ? configManager.renderWidth : configManager.renderHeight
    title: "GameLab Esports Dashboard"
    color: "#333333"

    // Hide system cursor when custom cursor is enabled
    flags: Qt.Window | Qt.FramelessWindowHint

    Component.onCompleted: {
        if (configManager.renderMouse === 1) {
            Qt.application.overrideCursor = Qt.BlankCursor
        }

        console.log("Window initialized - Mode:", configManager.renderScreen === 1 ? "FullScreen" : "Windowed",
                    "Dimensions:", width, "x", height, "Rotation:", configManager.renderRotate)
    }

    // Detect orientation
    property bool isPortrait: height > width

    // Handle resolution changes
    onWidthChanged: {
        console.log("Resolution changed - Width:", width, "Height:", height)
        Qt.callLater(adjustToResolution)
    }

    onHeightChanged: {
        console.log("Resolution changed - Width:", width, "Height:", height)
        Qt.callLater(adjustToResolution)
    }

    function adjustToResolution() {
        console.log("Adjusting UI to new resolution:", width, "x", height)
        // Force QML engine to re-evaluate all bindings and layouts
        // This ensures all components adjust to the new dimensions
    }

    // TOGGLE THIS: Set to true to use pixmap scrolling (last resort), false for fade in/out carousel
    property bool usePixmapScrolling: true

    // Font loaders
    FontLoader {
        id: openSansRegular
        source: "qrc:/fonts/OpenSans-Regular.ttf"
    }
    FontLoader {
        id: openSansBold
        source: "qrc:/fonts/OpenSans-Bold.ttf"
    }
    FontLoader {
        id: openSansSemiBold
        source: "qrc:/fonts/OpenSans-SemiBold.ttf"
    }

    // Color properties from config (dynamically loaded from gladis.ini)
    property string primaryColor: configManager.colorBg01
    property string accentColor: configManager.colorBg02
    property string textColor: configManager.colorText
    property string hoverColor: configManager.colorMain

    // Game images array (dynamically loaded from gladis.ini)
    property var gameImages: [
        configManager.helloSpinImg1,
        configManager.helloSpinImg2,
        configManager.helloSpinImg3,
        configManager.helloSpinImg4
    ]

    // Global MouseArea to hide system cursor
    // Note: This should be BEHIND all interactive elements
    MouseArea {
        anchors.fill: parent
        enabled: configManager.renderMouse === 1
        cursorShape: Qt.BlankCursor
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        hoverEnabled: false
        z: -1  // Behind everything to not block interactions
    }

    // Rotatable content container
    Item {
        id: contentContainer
        anchors.centerIn: parent
        width: configManager.renderWidth
        height: configManager.renderHeight
        rotation: configManager.renderRotate

        // Background with gradient using facility colors
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: mainWindow.primaryColor }
                GradientStop { position: 1.0; color: mainWindow.accentColor }
            }
        }

    // ===== DYNAMIC LAYER SYSTEM =====
    // Layer 0 is front-most (highest z-index)
    // Layers stack on top of each other like z-index in CSS
    // Empty layers show nothing

    // Layer 9 (bottom-most layer, z: 10)
    Loader {
        id: layer9Loader
        anchors.fill: parent
        z: 10
        active: configManager.layer9 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition9
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer9
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 9 loaded:", configManager.layer9)
            // Pass properties to the loaded component if needed
            if (item && configManager.layer9 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 8 (z: 20)
    Loader {
        id: layer8Loader
        anchors.fill: parent
        z: 20
        active: configManager.layer8 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition8
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer8
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 8 loaded:", configManager.layer8)
            if (item && configManager.layer8 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 7 (z: 30)
    Loader {
        id: layer7Loader
        anchors.fill: parent
        z: 30
        active: configManager.layer7 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition7
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer7
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 7 loaded:", configManager.layer7)
            if (item && configManager.layer7 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 6 (z: 40)
    Loader {
        id: layer6Loader
        anchors.fill: parent
        z: 40
        active: configManager.layer6 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition6
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer6
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 6 loaded:", configManager.layer6)
            if (item && configManager.layer6 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 5 (z: 50)
    Loader {
        id: layer5Loader
        anchors.fill: parent
        z: 50
        active: configManager.layer5 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition5
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer5
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 5 loaded:", configManager.layer5)
            if (item && configManager.layer5 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 4 (z: 60)
    Loader {
        id: layer4Loader
        anchors.fill: parent
        z: 60
        active: configManager.layer4 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition4
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer4
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 4 loaded:", configManager.layer4)
            if (item && configManager.layer4 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 3 (z: 70)
    Loader {
        id: layer3Loader
        anchors.fill: parent
        z: 70
        active: configManager.layer3 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition3
                easing.type: Easing.InOutQuad
            }
        }

        onLoaded: {
            console.log("Layer 3 loaded:", configManager.layer3)
            if (item && configManager.layer3 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }

        source: {
            var appName = configManager.layer3
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }
    }

    // Layer 2 (z: 80)
    Loader {
        id: layer2Loader
        anchors.fill: parent
        z: 80
        active: configManager.layer2 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition2
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer2
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 2 loaded:", configManager.layer2)
            if (item && configManager.layer2 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 1 (z: 90)
    Loader {
        id: layer1Loader
        anchors.fill: parent
        z: 90
        active: configManager.layer1 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition1
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer1
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 1 loaded:", configManager.layer1)
            if (item && configManager.layer1 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Layer 0 (front-most layer, z: 100)
    Loader {
        id: layer0Loader
        anchors.fill: parent
        z: 100
        active: configManager.layer0 !== ""
        opacity: active ? 1.0 : 0.0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: configManager.layerTransition0
                easing.type: Easing.InOutQuad
            }
        }

        source: {
            var appName = configManager.layer0
            if (appName === "app_hello") return "qrc:/Components/WelcomeApp.qml"
            if (appName === "app_timer") return "qrc:/Components/TimerApp.qml"
            if (appName === "app_image") return "qrc:/Components/ImageApp.qml"
            return ""
        }

        onLoaded: {
            console.log("Layer 0 loaded:", configManager.layer0)
            if (item && configManager.layer0 === "app_timer") {
                item.timerState = Qt.binding(function() { return configManager.timerState })
                item.timerCount = Qt.binding(function() { return configManager.timerCount })
                item.timerMax = Qt.binding(function() { return configManager.timerMax })
                item.timerText = Qt.binding(function() { return configManager.timerText })
                item.timerMenuLeft = Qt.binding(function() { return configManager.timerMenuLeft })
                item.timerMenuMiddle = Qt.binding(function() { return configManager.timerMenuMiddle })
                item.timerMenuRight = Qt.binding(function() { return configManager.timerMenuRight })
                item.colorMain = Qt.binding(function() { return configManager.colorMain })
                item.colorBg01 = Qt.binding(function() { return configManager.colorBg01 })
                item.colorBg02 = Qt.binding(function() { return configManager.colorBg02 })
                item.colorText = Qt.binding(function() { return configManager.colorText })
            }
        }
    }

    // Custom Cursor (tracking layer behind interactive elements)
    Item {
        id: cursorTracker
        anchors.fill: parent
        z: -10  // Well behind everything to not interfere

        property real mouseX: 0
        property real mouseY: 0

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: Qt.NoButton
            hoverEnabled: true

            onPositionChanged: function(mouse) {
                cursorTracker.mouseX = mouse.x
                cursorTracker.mouseY = mouse.y
                mouse.accepted = false
            }
        }
    }

    // Custom cursor image on top
    Image {
        id: customCursorImage
        width: 32
        height: 32
        visible: configManager.renderMouse === 1
        smooth: true
        z: 10000  // On top for visibility only

        x: cursorTracker.mouseX
        y: cursorTracker.mouseY

        source: {
            var filePath = configManager.mousePoint
            if (!filePath || filePath === "") {
                return ""
            }
            if (filePath.startsWith("qrc:/") || filePath.startsWith("file:")) {
                return filePath
            } else if (filePath.startsWith("/")) {
                return "file:" + filePath
            } else {
                return "qrc:/" + filePath
            }
        }
    }

    } // End of contentContainer
}
