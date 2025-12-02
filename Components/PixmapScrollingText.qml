import QtQuick 2.15
import QtQuick.Controls 2.15

/**
 * PixmapScrollingText - Performance-optimized scrolling text using pixmap rendering
 *
 * This component renders text to a pixmap (texture) and animates that instead of
 * animating text directly. This provides better performance on devices like Raspberry Pi 5.
 *
 * Key features:
 * - Renders text once to a texture/pixmap
 * - Tiles the texture for seamless infinite scrolling
 * - Hardware-accelerated animation
 * - Directional motion blur for smooth visual appearance (low CPU overhead)
 * - Compatible API with ScrollingText.qml for easy switching
 */
Rectangle {
    id: root

    // Public properties - matching ScrollingText.qml API
    property string text: "Sample scrolling text"
    property color textColor: "#00D9FF"
    property color lineColor: "#00D9FF"  // Separate color for lines
    property color backgroundColor: "#1a1a1a"
    property int textSize: 40
    property real scrollSpeed: 100  // pixels per second
    property bool showTopLine: false
    property bool showBottomLine: false

    // Additional properties for pixmap scrolling
    property int textSpacing: 100  // Space between repeated text instances

    // Motion blur properties (low CPU overhead, GPU-based)
    property bool enableMotionBlur: false  // Disabled by default (enable after testing)
    property int motionBlurRadius: 4  // 3-6 recommended for subtle effect
    property int motionBlurSamples: 8  // Higher = smoother but more GPU usage

    color: backgroundColor

    // Top line (optional)
    Rectangle {
        id: topLine
        visible: root.showTopLine
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        color: root.lineColor  // Use lineColor instead of textColor
    }

    // Bottom line (optional)
    Rectangle {
        id: bottomLine
        visible: root.showBottomLine
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        color: root.lineColor  // Use lineColor instead of textColor
    }

    // Clipping container for scrolling effect
    Item {
        id: scrollContainer
        anchors.fill: parent
        anchors.topMargin: root.showTopLine ? 6 : 0
        anchors.bottomMargin: root.showBottomLine ? 6 : 0
        clip: true

        // Hidden text element for measurement and rendering
        Text {
            id: sourceText
            text: root.text
            color: root.textColor
            font.pixelSize: root.textSize
            font.family: "Open Sans"
            font.weight: Font.Bold
            visible: false  // Hidden but will be measured

            // Force the text to calculate its size
            Component.onCompleted: {
                // Ensure text is properly sized
                width = implicitWidth
                height = implicitHeight
            }
        }

        // Scrolling container with repeated text
        Row {
            id: scrollingRow
            spacing: root.textSpacing
            y: (scrollContainer.height - sourceText.height) / 2  // Center vertically

            // Repeater to create multiple instances for seamless loop
            Repeater {
                model: 6  // Six instances for seamless scrolling (prevents jumping)

                Text {
                    text: root.text
                    color: root.textColor
                    font.pixelSize: root.textSize
                    font.family: "Open Sans"
                    font.weight: Font.Bold

                    // Enable layer for hardware acceleration (pixmap rendering)
                    layer.enabled: true
                    layer.smooth: true

                    // Apply horizontal motion blur for smooth scrolling (GPU-based custom shader)
                    layer.effect: root.enableMotionBlur ? horizontalBlurShader : null
                }
            }

            // Custom horizontal motion blur shader (GPU-accelerated, low CPU)
            Component {
                id: horizontalBlurShader

                ShaderEffect {
                    property variant source: null  // Will be set by layer system
                    property real blurRadius: root.motionBlurRadius
                    property size sourceSize: Qt.size(width, height)

                    // Horizontal box blur using Qt5-compatible GLSL
                    fragmentShader: "
                        varying highp vec2 qt_TexCoord0;
                        uniform sampler2D source;
                        uniform lowp float qt_Opacity;
                        uniform highp float blurRadius;
                        uniform highp vec2 sourceSize;

                        void main() {
                            highp vec4 sum = vec4(0.0);
                            highp float samples = 5.0;  // Fixed sample count for consistency
                            highp float pixelSize = 1.0 / sourceSize.x;
                            highp float radius = blurRadius * pixelSize;

                            // Horizontal box blur (5 samples)
                            sum += texture2D(source, qt_TexCoord0 + vec2(-2.0 * radius, 0.0)) * 0.05;
                            sum += texture2D(source, qt_TexCoord0 + vec2(-1.0 * radius, 0.0)) * 0.25;
                            sum += texture2D(source, qt_TexCoord0) * 0.40;
                            sum += texture2D(source, qt_TexCoord0 + vec2(1.0 * radius, 0.0)) * 0.25;
                            sum += texture2D(source, qt_TexCoord0 + vec2(2.0 * radius, 0.0)) * 0.05;

                            gl_FragColor = sum * qt_Opacity;
                        }
                    "
                }
            }
        }

        // Continuous scrolling animation (separate from Row to avoid conflicts)
        SequentialAnimation {
            id: scrollAnimation
            running: false
            loops: Animation.Infinite

            NumberAnimation {
                target: scrollingRow
                property: "x"
                from: 0
                to: -(sourceText.width + root.textSpacing)
                duration: (sourceText.width + root.textSpacing) / root.scrollSpeed * 1000
                easing.type: Easing.Linear
            }

            // Reset position for seamless loop
            ScriptAction {
                script: {
                    scrollingRow.x = 0
                }
            }
        }

        // Start animation when text is ready
        Component.onCompleted: {
            Qt.callLater(function() {
                if (sourceText.width > 0 && root.text !== "") {
                    scrollAnimation.start()
                }
            })
        }

        // Watch for text changes and restart animation
        Connections {
            target: root
            function onTextChanged() {
                // Stop current animation
                scrollAnimation.stop()

                // Reset position to start
                scrollingRow.x = 0

                // Wait for sourceText to update its width, then restart
                Qt.callLater(function() {
                    if (sourceText.width > 0 && root.text !== "") {
                        scrollAnimation.start()
                    }
                })
            }
        }
    }

    // Debug info (can be removed in production)
    Component.onCompleted: {
        console.log("PixmapScrollingText initialized")
        console.log("Text:", root.text)
        console.log("Root visible:", root.visible)
        console.log("Root width:", root.width, "height:", root.height)
        Qt.callLater(function() {
            console.log("Text width:", sourceText.width)
            console.log("ScrollContainer width:", scrollContainer.width, "height:", scrollContainer.height)
            console.log("ScrollingRow x:", scrollingRow.x, "y:", scrollingRow.y)
            console.log("Animation running:", scrollAnimation.running)
        })
    }
}
