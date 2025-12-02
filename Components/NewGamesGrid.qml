import QtQuick

Item {
    id: root

    property var gameImages: []
    property string textColor: "#FFFFFF"
    property string accentColor: "#FF5C00"
    property int currentImageIndex: 0

    width: 450
    height: 600

    // Timer for automatic rotation (3 seconds per game)
    Timer {
        id: rotationTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            root.currentImageIndex = (root.currentImageIndex + 1) % Math.max(1, root.gameImages.length)
        }
    }

    Column {
        anchors.fill: parent
        spacing: 20

        // Title
        Text {
            width: parent.width
            text: "NEW RELEASES"
            font.pixelSize: 36
            font.weight: Font.Normal
            font.family: "Open Sans"
            color: root.textColor
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            width: parent.width * 0.8
            height: 3
            color: root.accentColor
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // 2x2 Grid
        Grid {
            width: parent.width
            height: parent.height - 100
            columns: 2
            rows: 2
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: Math.min(4, root.gameImages.length)

                Item {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2

                    property bool isFocused: index === (root.currentImageIndex % 4)
                    property real targetScale: isFocused ? 1.08 : 1.0
                    property real targetRotation: isFocused ? 3 : 0

                    // Shadow effect
                    Rectangle {
                        anchors.fill: gameImageContainer
                        anchors.margins: -3
                        radius: 15
                        color: "#40000000"
                        opacity: 0.6
                        z: -1
                    }

                    Rectangle {
                        id: gameImageContainer
                        anchors.fill: parent
                        anchors.margins: 5
                        radius: 12
                        color: "#1a1a1a"
                        border.color: isFocused ? root.accentColor : "#003D7A"
                        border.width: isFocused ? 3 : 2
                        scale: targetScale
                        rotation: targetRotation
                        transformOrigin: Item.Center

                        Behavior on scale {
                            NumberAnimation {
                                duration: 600
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 600
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 400
                            }
                        }

                        Behavior on border.width {
                            NumberAnimation {
                                duration: 400
                            }
                        }

                        Image {
                            anchors.fill: parent
                            anchors.margins: 6
                            source: root.gameImages[index] || ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#ffffff"
                                border.width: 1
                                radius: 8
                            }
                        }
                    }
                }
            }
        }
    }
}
