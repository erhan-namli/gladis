import QtQuick

Item {
    id: root

    property string leftImageSource: ""
    property string rightImageSource: ""
    property int swapDuration: 2000 // Duration for swap animation in ms
    property int swapInterval: 4000 // Time between swaps in ms

    width: 800
    height: 400

    // State to track which image is on which side
    property bool isSwapped: false

    Row {
        anchors.fill: parent
        spacing: 20

        // Left position image
        Item {
            id: leftPosition
            width: (parent.width - parent.spacing) / 2
            height: parent.height

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                color: "#1a1a1a"
                radius: 12
                clip: true

                Image {
                    id: leftPosImage
                    anchors.fill: parent
                    source: root.isSwapped ? root.rightImageSource : root.leftImageSource
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true

                    Behavior on source {
                        SequentialAnimation {
                            NumberAnimation {
                                target: leftPosImage
                                property: "opacity"
                                to: 0
                                duration: root.swapDuration / 2
                            }
                            PropertyAction { target: leftPosImage; property: "source" }
                            NumberAnimation {
                                target: leftPosImage
                                property: "opacity"
                                to: 1
                                duration: root.swapDuration / 2
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 12
                }
            }
        }

        // Right position image
        Item {
            id: rightPosition
            width: (parent.width - parent.spacing) / 2
            height: parent.height

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                color: "#1a1a1a"
                radius: 12
                clip: true

                Image {
                    id: rightPosImage
                    anchors.fill: parent
                    source: root.isSwapped ? root.leftImageSource : root.rightImageSource
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true

                    Behavior on source {
                        SequentialAnimation {
                            NumberAnimation {
                                target: rightPosImage
                                property: "opacity"
                                to: 0
                                duration: root.swapDuration / 2
                            }
                            PropertyAction { target: rightPosImage; property: "source" }
                            NumberAnimation {
                                target: rightPosImage
                                property: "opacity"
                                to: 1
                                duration: root.swapDuration / 2
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#ffffff"
                    border.width: 2
                    radius: 12
                }
            }
        }
    }

    // Timer to trigger swap
    Timer {
        running: true
        repeat: true
        interval: root.swapInterval
        onTriggered: {
            root.isSwapped = !root.isSwapped
        }
    }
}
