import QtQuick

Item {
    id: root

    property var scheduleData: ({})
    property string textColor: "#FFFFFF"
    property string accentColor: "#FF5C00"
    property string titleText: "LAB HOURS"
    property string todayName: Qt.formatDate(new Date(), "dddd").toLowerCase()

    // Function to get next 7 days starting from today
    function getNext7Days() {
        var days = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        var labels = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
        var today = new Date()
        var todayIndex = today.getDay()
        var result = []

        for (var i = 0; i < 7; i++) {
            var dayIndex = (todayIndex + i) % 7
            var date = new Date(today)
            date.setDate(today.getDate() + i)
            result.push({
                day: days[dayIndex],
                label: i === 0 ? "TODAY" : labels[dayIndex],
                isToday: i === 0,
                date: Qt.formatDate(date, "MMM d")
            })
        }
        return result
    }

    width: 400
    height: 600

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

            // Schedule list
            Column {
                width: parent.width
                spacing: 8

                Repeater {
                    model: root.getNext7Days()

                    delegate: Item {
                        width: parent.width
                        height: 70

                        property var dayData: root.scheduleData.data ? root.scheduleData.data[modelData.day] : null
                        property bool isToday: modelData.isToday
                        property bool isClosed: dayData ? dayData.is_closed === 1 : false
                        property string startTime: dayData && !isClosed ? formatTime(dayData.start) : ""
                        property string endTime: dayData && !isClosed ? formatTime(dayData.end) : ""

                        function formatTime(timeStr) {
                            if (!timeStr) return ""
                            var parts = timeStr.split(":")
                            var hour = parseInt(parts[0])
                            var minute = parts[1]
                            var ampm = hour >= 12 ? "p" : "a"  // lowercase a/p
                            hour = hour % 12
                            if (hour === 0) hour = 12
                            return hour + ":" + minute + ampm  // No space before a/p
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: isToday ? root.accentColor : "transparent"  // TODAY filled with cyan, others transparent
                            border.color: root.accentColor  // Cyan border for all
                            border.width: 3
                            opacity: 1.0
                            radius: height / 2  // Full pill shape (completely rounded ends)

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 35  // Space for rounded left edge
                                anchors.rightMargin: 35  // Space for rounded right edge
                                anchors.topMargin: 12
                                anchors.bottomMargin: 12
                                spacing: 10

                                // Day label
                                Text {
                                    width: 120
                                    height: parent.height
                                    text: modelData.label
                                    font.pixelSize: isToday ? 24 : 20
                                    font.bold: true
                                    font.family: "Open Sans"
                                    color: root.textColor  // Use facility textColor
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                }

                                // Time range
                                Text {
                                    width: parent.width - 130
                                    height: parent.height
                                    text: isClosed ? "CLOSED" : (startTime + " - " + endTime)
                                    font.pixelSize: isToday ? 20 : 18
                                    font.bold: isToday
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
}
