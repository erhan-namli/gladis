import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var gameImages: []
    property int currentIndex: 0
    property int cardCount: gameImages.length

    width: parent.width
    height: 350

    // Timer for automatic rotation
    Timer {
        id: rotationTimer
        interval: 4000
        running: true
        repeat: true
        onTriggered: {
            root.currentIndex = (root.currentIndex + 1) % root.cardCount
        }
    }

    // Carousel container
    Item {
        id: carouselContainer
        anchors.centerIn: parent
        width: root.width
        height: root.height

        Repeater {
            model: root.cardCount

            Item {
                id: card
                width: 300
                height: 300

                property int cardIndex: index
                property real angleOffset: (360.0 / root.cardCount) * cardIndex
                property real currentAngle: angleOffset - (root.currentIndex * (360.0 / root.cardCount))
                property bool isCenterCard: false

                // Position calculation for circular carousel
                x: {
                    var radiusX = root.width * 0.28
                    var centerX = (root.width - width) / 2
                    var angle = currentAngle * Math.PI / 180
                    return centerX + radiusX * Math.sin(angle)
                }

                y: {
                    var radiusY = root.height * 0.15
                    var centerY = (root.height - height) / 2
                    var angle = currentAngle * Math.PI / 180
                    return centerY + radiusY * Math.cos(angle)
                }

                // Z-index based on scale and position (larger cards in front)
                // This prevents cards from popping in front before they grow larger
                z: {
                    var normalizedAngle = ((currentAngle % 360) + 360) % 360
                    if (normalizedAngle > 180) normalizedAngle = 360 - normalizedAngle

                    // Z-index primarily based on scale (size determines depth)
                    // Scale range: 0.336 to 0.624, map to z-index range
                    var scaleZ = scale * 200  // 0.336→67.2, 0.624→124.8

                    // Add small angle component to break ties (closer to center = slightly higher)
                    var angleBonus = (90 - Math.abs(normalizedAngle)) * 0.05  // 0 to 4.5

                    return scaleZ + angleBonus
                }

                // Scale based on position - smooth continuous growth/shrink for 3D depth
                scale: {
                    var normalizedAngle = ((currentAngle % 360) + 360) % 360
                    if (normalizedAngle > 180) normalizedAngle = 360 - normalizedAngle

                    if (Math.abs(normalizedAngle) < 5) {
                        // Very center card is largest
                        isCenterCard = true
                        return 0.624
                    } else if (Math.abs(normalizedAngle) < 45) {
                        // Smooth transition: grows from 0.374 at 45° to 0.624 at 5°
                        isCenterCard = false
                        var factor = (45 - Math.abs(normalizedAngle)) / 40  // 0 to 1
                        return 0.374 + (factor * 0.25)  // Interpolate from 0.374 to 0.624
                    } else {
                        // Back cards stay small
                        isCenterCard = false
                        return Math.max(0.336, 0.374 - ((Math.abs(normalizedAngle) - 45) / 315) * 0.04)
                    }
                }

                // Opacity based on position
                opacity: {
                    var normalizedAngle = ((currentAngle % 360) + 360) % 360
                    if (normalizedAngle > 180) normalizedAngle = 360 - normalizedAngle

                    if (Math.abs(normalizedAngle) < 20) {
                        return 1.0
                    } else {
                        return 0.5 + (1.0 - Math.abs(normalizedAngle) / 180.0) * 0.5
                    }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }
                }

                // Soft blurred shadow using RadialGradient
                Rectangle {
                    id: cardShadow
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 25
                    width: parent.width * 0.9
                    height: 30
                    radius: height / 2
                    opacity: card.opacity * 0.6

                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "#50000000" }
                        GradientStop { position: 0.5; color: "#30000000" }
                        GradientStop { position: 1.0; color: "#00000000" }
                    }
                }

                // Image (hidden, used as source for mask)
                Image {
                    id: gameImage
                    anchors.fill: parent
                    source: root.gameImages[card.cardIndex] || ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true
                    visible: false
                }

                // Rounded rectangle mask (hidden)
                Rectangle {
                    id: maskRect
                    anchors.fill: parent
                    radius: 15
                    visible: false
                }

                // Apply rounded mask to image
                OpacityMask {
                    anchors.fill: parent
                    source: gameImage
                    maskSource: maskRect
                }
            }
        }
    }
}
