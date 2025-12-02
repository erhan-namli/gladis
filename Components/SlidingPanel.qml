import QtQuick

Item {
    id: root

    property string text: ""
    property string textColor: "#FFFFFF"
    property string backgroundColor: "#FF5C00"
    property int animationDuration: 15000
    property bool isTop: true

    width: parent.width
    height: 60

    clip: true

    Rectangle {
        id: panel
        width: parent.width
        height: parent.height
        color: root.backgroundColor

        // Animated text
        Row {
            id: textRow
            spacing: 100
            height: parent.height
            y: (parent.height - height) / 2

            Repeater {
                model: 3 // Repeat text 3 times for seamless loop

                Text {
                    text: root.text
                    font.pixelSize: 28
                    font.bold: true
                    font.family: "Open Sans"
                    color: root.textColor
                    verticalAlignment: Text.AlignVCenter
                    height: panel.height
                }
            }
        }

        // Animation
        SequentialAnimation {
            id: slideAnimation
            running: true
            loops: Animation.Infinite

            NumberAnimation {
                target: textRow
                property: "x"
                from: root.width
                to: -(textRow.width / 3)
                duration: root.animationDuration
                easing.type: Easing.Linear
            }

            ScriptAction {
                script: {
                    textRow.x = root.width
                }
            }
        }
    }

    Component.onCompleted: {
        slideAnimation.start()
    }
}
