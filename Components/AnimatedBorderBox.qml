import QtQuick

// Animated gradient border box inspired by CSS animated borders
Item {
    id: root

    property color color1: "#fb6502" // accent color
    property color color2: "#00529b" // base color
    property real borderWidth: 3
    property real animationSpeed: 3000 // milliseconds for one complete cycle

    // Content area (children will be placed here)
    default property alias contentData: contentArea.data

    // Background
    Rectangle {
        id: background
        anchors.fill: parent
        color: "#003D7A"
        opacity: 0.9
        radius: 10
        z: 1
    }

    // Content container
    Item {
        id: contentArea
        anchors.fill: parent
        z: 2
    }

    // Animated border effect using 4 rotating rectangles
    Repeater {
        model: 4

        Rectangle {
            id: borderSegment
            width: index % 2 === 0 ? parent.width : borderWidth
            height: index % 2 === 0 ? borderWidth : parent.height

            x: {
                if (index === 0) return 0
                if (index === 1) return parent.width - borderWidth
                if (index === 2) return 0
                return 0
            }

            y: {
                if (index === 0) return 0
                if (index === 1) return 0
                if (index === 2) return parent.height - borderWidth
                return 0
            }

            gradient: Gradient {
                orientation: index % 2 === 0 ? Gradient.Horizontal : Gradient.Vertical

                GradientStop {
                    position: 0.0 + animationOffset
                    color: root.color1
                }
                GradientStop {
                    position: 0.5 + animationOffset
                    color: root.color2
                }
                GradientStop {
                    position: 1.0 + animationOffset
                    color: root.color1
                }
            }

            property real animationOffset: 0

            SequentialAnimation on animationOffset {
                running: true
                loops: Animation.Infinite

                NumberAnimation {
                    from: 0.0
                    to: 1.0
                    duration: root.animationSpeed
                    easing.type: Easing.Linear
                }

                ScriptAction {
                    script: borderSegment.animationOffset = 0
                }
            }

            z: 0
        }
    }
}
