import QtQuick

Item {
    id: root

    property var playerData: ({})
    property var platformList: []
    property string textColor: "#FFFFFF"
    property string accentColor: "#FF5C00"
    property string titleText: "PLAYERS"

    width: 450
    height: 350

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Column {
            anchors.fill: parent
            spacing: 15

            // Title
            Text {
                width: parent.width
                text: root.titleText
                font.pixelSize: 36
                font.weight: Font.Normal
                font.family: "Open Sans"
                color: root.textColor
                horizontalAlignment: Text.AlignHCenter
            }

            // Stats grid - dynamically generated from platformList
            Column {
                width: parent.width
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                // Dynamic platform entries using Repeater
                Repeater {
                    model: root.platformList

                    Item {
                        width: parent ? parent.width * 0.9 : 0
                        height: 70
                        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

                        // Show total filled in, others empty
                        property bool isTotal: modelData.index === 0
                        property int displayValue: modelData.total || 0
                        property bool shouldShow: displayValue > 0 || isTotal

                        visible: shouldShow

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: isTotal ? root.accentColor : "transparent"
                            border.color: root.accentColor
                            border.width: 3
                            opacity: 1.0
                            radius: height / 2

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 35
                                anchors.rightMargin: 35
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 10

                                // Platform icon
                                Item {
                                    width: isTotal ? 0 : 30
                                    height: 30
                                    visible: !isTotal
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        anchors.fill: parent
                                        source: modelData.icon ? (modelData.icon.startsWith("assets/") ? "qrc:/" + modelData.icon : "file:" + modelData.icon) : ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        sourceSize.width: 64
                                        sourceSize.height: 64
                                        asynchronous: true

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.category ? modelData.category.substring(0, 2) : "?"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: root.textColor
                                            visible: parent.status === Image.Error
                                        }
                                    }
                                }

                                // Platform name
                                Text {
                                    width: isTotal ? 120 : (parent.width - 90)
                                    height: parent.height
                                    text: modelData.category || ""
                                    font.pixelSize: isTotal ? 24 : 22
                                    font.bold: true
                                    font.family: "Open Sans"
                                    color: root.textColor
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: isTotal ? Text.AlignLeft : Text.AlignLeft
                                }

                                // Count
                                Text {
                                    width: isTotal ? (parent.width - 130) : 40
                                    height: parent.height
                                    text: displayValue
                                    font.pixelSize: 28
                                    font.bold: true
                                    font.family: "Open Sans"
                                    color: root.textColor
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Animation for data updates
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    // Debug output
    Component.onCompleted: {
        console.log("PlayerStats loaded with", root.platformList.length, "platforms")
        for (var i = 0; i < root.platformList.length; i++) {
            console.log("  Platform", i, ":", root.platformList[i].category, "-", root.platformList[i].total)
        }
    }

    // Watch for platform list changes
    onPlatformListChanged: {
        console.log("Platform list changed, now has", root.platformList.length, "platforms")
    }
}
