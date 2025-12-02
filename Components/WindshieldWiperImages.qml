import QtQuick

Item {
    id: root

    property string leftImageSource: ""
    property string rightImageSource: ""
    property string animationState: "equal"  // Three states: "leftBigger", "equal", "rightBigger"
    property int carouselIndex: 0  // Synced with carousel rotation
    property int stateCounter: 0  // Counter to alternate between left and right bigger states

    width: 800
    height: 400

    // Timer to transition from "equal" to "leftBigger" or "rightBigger" after carousel animation completes
    Timer {
        id: transitionTimer
        interval: 800  // Match carousel animation duration (800ms)
        running: false
        onTriggered: {
            // After carousel animation completes, transition to bigger state (alternating)
            animationState = (stateCounter % 2 === 0) ? "leftBigger" : "rightBigger"
            stateCounter++
        }
    }

    // Trigger transitions on every carousel index change
    onCarouselIndexChanged: {
        // When carousel changes, first show "equal" state
        animationState = "equal"
        // Then after 800ms (carousel animation duration), transition to left/right bigger
        transitionTimer.restart()
    }

    // Container for images spread apart
    Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        // Left image (always shows left source)
        Item {
            id: leftPosItem
            anchors.left: parent.left
            anchors.leftMargin: root.animationState === "leftBigger" ? parent.width * 0.20 :
                               root.animationState === "equal" ? parent.width * 0.05 :
                               parent.width * 0.15  // rightBigger
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.35
            height: parent.height * 0.85

            scale: root.animationState === "leftBigger" ? 2.16 :
                   root.animationState === "equal" ? 1.89 :
                   1.62  // rightBigger (small)

            Behavior on anchors.leftMargin {
                NumberAnimation {
                    duration: 800  // Match carousel rotation speed
                    easing.type: Easing.InOutQuad
                }
            }

            // Z-index based on actual scale comparison with right image
            // Only come to front when actually bigger than the right side
            z: scale > rightPosItem.scale ? 2 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 800  // Match carousel rotation speed
                    easing.type: Easing.InOutQuad
                }
            }

            // Rounded image container
            Rectangle {
                anchors.fill: parent
                radius: 50
                color: "transparent"
                clip: true

                Image {
                    id: leftPosImage
                    anchors.fill: parent
                    source: root.leftImageSource
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true
                }
            }
        }

        // Right image (always shows right source)
        Item {
            id: rightPosItem
            anchors.right: parent.right
            anchors.rightMargin: root.animationState === "rightBigger" ? parent.width * 0.20 :
                                root.animationState === "equal" ? parent.width * 0.05 :
                                parent.width * 0.15  // leftBigger
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * 0.35
            height: parent.height * 0.85

            scale: root.animationState === "rightBigger" ? 2.16 :
                   root.animationState === "equal" ? 1.89 :
                   1.62  // leftBigger (small)

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: 800  // Match carousel rotation speed
                    easing.type: Easing.InOutQuad
                }
            }

            // Z-index based on actual scale comparison with left image
            // Only come to front when actually bigger than the left side
            z: scale > leftPosItem.scale ? 2 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 800  // Match carousel rotation speed
                    easing.type: Easing.InOutQuad
                }
            }

            // Rounded image container
            Rectangle {
                anchors.fill: parent
                radius: 15
                color: "transparent"
                clip: true

                Image {
                    id: rightPosImage
                    anchors.fill: parent
                    source: root.rightImageSource
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true
                }
            }
        }
    }
}
