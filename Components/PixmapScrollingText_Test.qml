import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

/**
 * Test window for PixmapScrollingText component
 *
 * Run this with: qml PixmapScrollingText_Test.qml
 * Or integrate into your main.qml for testing
 */
Window {
    id: testWindow
    visible: true
    width: 1920
    height: 1080
    title: "PixmapScrollingText Test"
    color: "#0a0a0a"

    Column {
        anchors.fill: parent
        spacing: 20

        // Title
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "PixmapScrollingText Component Test"
            color: "#00D9FF"
            font.pixelSize: 32
            font.bold: true
            topPadding: 20
        }

        // Test 1: Basic scrolling text
        Rectangle {
            width: parent.width
            height: 100
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 1

            Column {
                anchors.fill: parent

                Text {
                    text: "Test 1: Basic Scrolling"
                    color: "#999999"
                    font.pixelSize: 14
                    leftPadding: 10
                    topPadding: 5
                }

                PixmapScrollingText {
                    width: parent.width
                    height: 60
                    text: "Welcome to GameLab - Your Premier Gaming Experience!"
                    textColor: "#00D9FF"
                    backgroundColor: "#1a1a1a"
                    textSize: 40
                    scrollSpeed: 100
                    showBottomLine: true
                }
            }
        }

        // Test 2: Faster scrolling
        Rectangle {
            width: parent.width
            height: 100
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 1

            Column {
                anchors.fill: parent

                Text {
                    text: "Test 2: Faster Speed (150 px/s)"
                    color: "#999999"
                    font.pixelSize: 14
                    leftPadding: 10
                    topPadding: 5
                }

                PixmapScrollingText {
                    width: parent.width
                    height: 60
                    text: "FAST SCROLLING - Events | Tournaments | Prizes | Gaming | Fun | Competition"
                    textColor: "#FFD700"
                    backgroundColor: "#1a1a1a"
                    textSize: 40
                    scrollSpeed: 150
                    showTopLine: true
                    showBottomLine: true
                }
            }
        }

        // Test 3: Slower scrolling with more spacing
        Rectangle {
            width: parent.width
            height: 100
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 1

            Column {
                anchors.fill: parent

                Text {
                    text: "Test 3: Slower Speed (60 px/s) with Wide Spacing (200px)"
                    color: "#999999"
                    font.pixelSize: 14
                    leftPadding: 10
                    topPadding: 5
                }

                PixmapScrollingText {
                    width: parent.width
                    height: 60
                    text: "⭐ SPECIAL ANNOUNCEMENT ⭐"
                    textColor: "#FF6B9D"
                    backgroundColor: "#1a1a1a"
                    textSize: 40
                    scrollSpeed: 60
                    textSpacing: 200
                    showBottomLine: true
                }
            }
        }

        // Test 4: Long text
        Rectangle {
            width: parent.width
            height: 100
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 1

            Column {
                anchors.fill: parent

                Text {
                    text: "Test 4: Very Long Text"
                    color: "#999999"
                    font.pixelSize: 14
                    leftPadding: 10
                    topPadding: 5
                }

                PixmapScrollingText {
                    width: parent.width
                    height: 60
                    text: "This is a much longer text message to test how the pixmap scrolling handles extended content with multiple words and phrases strung together continuously"
                    textColor: "#00FF88"
                    backgroundColor: "#1a1a1a"
                    textSize: 36
                    scrollSpeed: 120
                    textSpacing: 150
                    showTopLine: true
                }
            }
        }

        // Test 5: Smaller text size
        Rectangle {
            width: parent.width
            height: 80
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 1

            Column {
                anchors.fill: parent

                Text {
                    text: "Test 5: Smaller Font (24px)"
                    color: "#999999"
                    font.pixelSize: 14
                    leftPadding: 10
                    topPadding: 5
                }

                PixmapScrollingText {
                    width: parent.width
                    height: 50
                    text: "Small text scrolling - GameLab 2024 - Join our community!"
                    textColor: "#A0A0FF"
                    backgroundColor: "#1a1a1a"
                    textSize: 24
                    scrollSpeed: 80
                }
            }
        }

        // Instructions
        Rectangle {
            width: parent.width - 40
            height: 150
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#2a2a2a"
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                Text {
                    text: "How to Use in main.qml:"
                    color: "#00D9FF"
                    font.pixelSize: 18
                    font.bold: true
                }

                Text {
                    text: "1. Simply replace 'ScrollingText' with 'PixmapScrollingText' in your main.qml"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Text {
                    text: "2. All properties are compatible (text, textColor, backgroundColor, textSize, scrollSpeed, etc.)"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Text {
                    text: "3. Adjust 'scrollSpeed' for desired animation speed (lower = slower, higher = faster)"
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }
    }
}
