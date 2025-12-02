import QtQuick

Item {
    id: root

    property string imageSource: ""
    property bool isActive: false
    property real cardScale: 1.0
    property real cardOpacity: 1.0
    property real rotationAngle: 0

    width: 300
    height: 300  // Square aspect ratio

    // Shadow effect that moves with the card
    Rectangle {
        id: cardShadow
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: 15
        color: "#40000000"
        opacity: 0.6 * root.cardOpacity
        z: -1
        scale: root.cardScale
        rotation: root.rotationAngle
        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Behavior on rotation {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Wrapper item for transformations
    Item {
        id: cardWrapper
        anchors.fill: parent
        scale: root.cardScale
        opacity: root.cardOpacity
        rotation: root.rotationAngle
        transformOrigin: Item.Center

        Behavior on scale {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on rotation {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        // Card with rounded corners using solid background
        Rectangle {
            id: cardBackground
            anchors.fill: parent
            radius: 15
            color: "#3a3a3c"  // Match main background color instead of transparent
            clip: true

            Image {
                id: gameImage
                anchors.fill: parent
                source: root.imageSource
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
            }
        }
    }
}
