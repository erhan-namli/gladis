import QtQuick

Item {
    id: root

    property var playerData: ({})
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
                color: root.textColor  // Use facility textColor
                horizontalAlignment: Text.AlignHCenter
            }

            // Stats grid
            Column {
                width: parent.width
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                // Total players (matches LAB HOURS style)
                Item {
                    width: parent.width * 0.9
                    height: 70
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        color: root.accentColor  // TOTAL filled with cyan
                        border.color: root.accentColor  // Cyan border
                        border.width: 3
                        opacity: 1.0
                        radius: height / 2  // Full pill shape

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 35  // Match LAB HOURS margins
                            anchors.rightMargin: 35
                            anchors.topMargin: 12
                            anchors.bottomMargin: 12
                            spacing: 10

                            Text {
                                width: 120
                                height: parent.height
                                text: "TOTAL"
                                font.pixelSize: 24
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                            }

                            Text {
                                width: parent.width - 130
                                height: parent.height
                                text: root.playerData.total || "0"
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                // Platform-specific stats
                Column {
                    width: parent.width * 0.9
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8  // Match LAB HOURS spacing

                    // Xbox
                    Item {
                        width: parent.width
                        height: 70
                        visible: (root.playerData.xbox || 0) > 0

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "transparent"  // Empty box
                            border.color: root.accentColor  // Cyan border
                            border.width: 3
                            opacity: 1.0
                            radius: height / 2  // Full pill shape

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 35  // Match LAB HOURS margins
                                anchors.rightMargin: 35
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 10

                            Item {
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/assets/icon_xbox.svg"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    sourceSize.width: 64
                                    sourceSize.height: 64
                                    asynchronous: true

                                    // Fallback if SVG fails
                                    Text {
                                        anchors.centerIn: parent
                                        text: "X"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "#FFFFFF"
                                        visible: parent.status === Image.Error
                                    }
                                }
                            }

                            Text {
                                width: parent.width - 90
                                height: parent.height
                                text: "XBOX"
                                font.pixelSize: 22
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: 40
                                height: parent.height
                                text: root.playerData.xbox || "0"
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                    }

                    // Windows/PC
                    Item {
                        width: parent.width
                        height: 70
                        visible: (root.playerData.pc || 0) > 0

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "transparent"  // Empty box
                            border.color: root.accentColor  // Cyan border
                            border.width: 3
                            opacity: 1.0
                            radius: height / 2  // Full pill shape

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 35  // Match LAB HOURS margins
                                anchors.rightMargin: 35
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 10

                            Item {
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/assets/icon_pc.svg"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    sourceSize.width: 64
                                    sourceSize.height: 64
                                    asynchronous: true

                                    Text {
                                        anchors.centerIn: parent
                                        text: "PC"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#FFFFFF"
                                        visible: parent.status === Image.Error
                                    }
                                }
                            }

                            Text {
                                width: parent.width - 90
                                height: parent.height
                                text: "PC"
                                font.pixelSize: 22
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: 40
                                height: parent.height
                                text: root.playerData.pc || "0"
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                    }

                    // Nintendo Switch
                    Item {
                        width: parent.width
                        height: 70
                        visible: (root.playerData.switch || 0) > 0

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "transparent"  // Empty box
                            border.color: root.accentColor  // Cyan border
                            border.width: 3
                            opacity: 1.0
                            radius: height / 2  // Full pill shape

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 35  // Match LAB HOURS margins
                                anchors.rightMargin: 35
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 10

                            Item {
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/assets/icon_switch.svg"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    sourceSize.width: 64
                                    sourceSize.height: 64
                                    asynchronous: true

                                    Text {
                                        anchors.centerIn: parent
                                        text: "SW"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#FFFFFF"
                                        visible: parent.status === Image.Error
                                    }
                                }
                            }

                            Text {
                                width: parent.width - 90
                                height: parent.height
                                text: "SWITCH"
                                font.pixelSize: 22
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: 40
                                height: parent.height
                                text: root.playerData.switch || "0"
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                    }

                    // PS5
                    Item {
                        width: parent.width
                        height: 70
                        visible: (root.playerData.ps5 || 0) > 0

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "transparent"  // Empty box
                            border.color: root.accentColor  // Cyan border
                            border.width: 3
                            opacity: 1.0
                            radius: height / 2  // Full pill shape

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 35  // Match LAB HOURS margins
                                anchors.rightMargin: 35
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 10

                            Item {
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    anchors.fill: parent
                                    source: "qrc:/assets/icon_ps5.svg"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    sourceSize.width: 64
                                    sourceSize.height: 64
                                    asynchronous: true

                                    Text {
                                        anchors.centerIn: parent
                                        text: "PS"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#FFFFFF"
                                        visible: parent.status === Image.Error
                                    }
                                }
                            }

                            Text {
                                width: parent.width - 90
                                height: parent.height
                                text: "PS5"
                                font.pixelSize: 22
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: 40
                                height: parent.height
                                text: root.playerData.ps5 || "0"
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                    }

                    // Arcade
                    Item {
                        width: parent.width
                        height: 70
                        visible: (root.playerData.arcade || 0) > 0

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "transparent"  // Empty box
                            border.color: root.accentColor  // Cyan border
                            border.width: 3
                            opacity: 1.0
                            radius: height / 2  // Full pill shape

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 35  // Match LAB HOURS margins
                                anchors.rightMargin: 35
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 10

                            Item {
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "🕹"
                                    font.pixelSize: 24
                                    visible: true
                                }
                            }

                            Text {
                                width: parent.width - 90
                                height: parent.height
                                text: "ARCADE"
                                font.pixelSize: 22
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: 40
                                height: parent.height
                                text: root.playerData.arcade || "0"
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "Open Sans"
                                color: root.textColor  // Use facility textColor
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
}
