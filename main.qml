import QtQuick
import QtQuick.Window
import "Components"

Window {
    id: mainWindow
    visible: true
    visibility: Window.FullScreen
    // Dynamic resolution from config (default 1080x1920 portrait for app_hello)
    width: configManager.renderWidth
    height: configManager.renderHeight
    title: "GameLab Esports Dashboard"
    color: "#333333"

    // Detect orientation
    property bool isPortrait: height > width

    // Active layer from config
    property string activeLayer: configManager.layer0

    // Handle resolution changes
    onWidthChanged: {
        console.log("Resolution changed - Width:", width, "Height:", height)
        Qt.callLater(adjustToResolution)
    }

    onHeightChanged: {
        console.log("Resolution changed - Width:", width, "Height:", height)
        Qt.callLater(adjustToResolution)
    }

    function adjustToResolution() {
        console.log("Adjusting UI to new resolution:", width, "x", height)
        // Force QML engine to re-evaluate all bindings and layouts
        // This ensures all components adjust to the new dimensions
    }

    // TOGGLE THIS: Set to true to use pixmap scrolling (last resort), false for fade in/out carousel
    property bool usePixmapScrolling: true

    // Font loaders
    FontLoader {
        id: openSansRegular
        source: "qrc:/fonts/OpenSans-Regular.ttf"
    }
    FontLoader {
        id: openSansBold
        source: "qrc:/fonts/OpenSans-Bold.ttf"
    }
    FontLoader {
        id: openSansSemiBold
        source: "qrc:/fonts/OpenSans-SemiBold.ttf"
    }

    // Color properties from config (dynamically loaded from glad is.ini)
    property string primaryColor: configManager.colorBg01
    property string accentColor: configManager.colorBg02
    property string textColor: configManager.colorText
    property string hoverColor: configManager.colorMain

    // Game images array (dynamically loaded from gladis.ini)
    property var gameImages: [
        configManager.helloSpinImg1,
        configManager.helloSpinImg2,
        configManager.helloSpinImg3,
        configManager.helloSpinImg4
    ]


// OLD CONTENT MOVED TO HelloApp.qml (will create next)

    // Background with gradient using facility colors
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: mainWindow.primaryColor }
            GradientStop { position: 1.0; color: mainWindow.accentColor }
        }
    }

    // Top scrolling banner (switchable between fade carousel and pixmap scrolling)
    Loader {
        id: topScroll
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60

        sourceComponent: mainWindow.usePixmapScrolling ? pixmapTopScroll : fadeTopScroll

        Component {
            id: fadeTopScroll
            ScrollingText {
                text: configManager.helloNews1
                textColor: mainWindow.textColor
                backgroundColor: "#1a1a1a"
                textSize: 40
                showBottomLine: true
                scrollSpeed: 150
            }
        }

        Component {
            id: pixmapTopScroll
            PixmapScrollingText {
                anchors.fill: parent
                text: configManager.helloNews1
                textColor: mainWindow.textColor
                lineColor: mainWindow.hoverColor
                backgroundColor: "#1a1a1a"
                textSize: 40
                showBottomLine: true
                scrollSpeed: 100
                textSpacing: 150
                enableMotionBlur: false
                motionBlurRadius: 4
            }
        }
    }

    // Stationary banner image
    Image {
        id: bannerImage
        anchors.top: topScroll.bottom
        anchors.topMargin: 40
        anchors.left: parent.left
        anchors.right: parent.right
        height: sourceSize.height > 0 ? sourceSize.height : 60
        source: configManager.helloLead ? "file:" + configManager.helloLead : ""
        fillMode: Image.PreserveAspectFit
        smooth: true
        asynchronous: true
        visible: status === Image.Ready
    }

    // Bottom scrolling banner (switchable between fade carousel and pixmap scrolling)
    Loader {
        id: bottomScroll
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60

        sourceComponent: mainWindow.usePixmapScrolling ? pixmapBottomScroll : fadeBottomScroll

        Component {
            id: fadeBottomScroll
            ScrollingText {
                text: configManager.helloNews2
                textColor: mainWindow.textColor
                backgroundColor: "#1a1a1a"
                textSize: 40
                showTopLine: true
                scrollSpeed: 150
            }
        }

        Component {
            id: pixmapBottomScroll
            PixmapScrollingText {
                anchors.fill: parent
                text: configManager.helloNews2
                textColor: mainWindow.textColor
                lineColor: mainWindow.hoverColor
                backgroundColor: "#1a1a1a"
                textSize: 40
                showTopLine: true
                scrollSpeed: 100
                textSpacing: 150
                enableMotionBlur: false
                motionBlurRadius: 4
            }
        }
    }

    // Logo area: 1080x270px, positioned at (0, 270) from top corner of viewport
    // If logo is 1080x270: display as-is
    // If smaller: center without scaling
    // If larger: scale down proportionally to fit
    Item {
        id: logoContainer
        x: 0
        y: 270
        width: 1080
        height: 270
        anchors.horizontalCenter: parent.horizontalCenter

        Loader {
            id: logo
            anchors.fill: parent

            sourceComponent: dataManager.facilityLogoIsGif ? animatedLogoComponent : staticLogoComponent

            Component {
                id: staticLogoComponent
                Image {
                    id: logoImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: configManager.helloMain ? "file:" + configManager.helloMain : ""
                    fillMode: (sourceSize.width > 0 && sourceSize.width <= 1080 && sourceSize.height <= 270)
                              ? Image.Pad : Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true
                }
            }

            Component {
                id: animatedLogoComponent
                AnimatedImage {
                    id: animatedLogoImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: configManager.helloMain ? "file:" + configManager.helloMain : ""
                    fillMode: (sourceSize.width > 0 && sourceSize.width <= 1080 && sourceSize.height <= 270)
                              ? Image.Pad : Image.PreserveAspectFit
                    smooth: true
                    playing: true
                }
            }
        }
    }

    // Main content area
    Item {
        id: mainContent
        anchors.top: logoContainer.bottom
        anchors.topMargin: -60
        anchors.bottom: bottomScroll.top
        anchors.left: parent.left
        anchors.right: parent.right

        // NEW RELEASES section: Carousel on left (vertical with title), WindshieldWiper on right
        Item {
            id: newReleasesArea
            anchors.top: parent.top
            anchors.topMargin: 120
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9
            height: Math.min(parent.height * 0.3, 400)

            property bool hasWiperImages: configManager.helloShow1 !== "" && configManager.helloShow2 !== ""

            // Centered layout when wiper images are missing
            Item {
                visible: !newReleasesArea.hasWiperImages
                anchors.fill: parent

                // NEW RELEASES Title
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: configManager.helloSpinText
                    font.pixelSize: 36
                    font.weight: Font.Normal
                    font.family: "Open Sans"
                    color: mainWindow.textColor
                    horizontalAlignment: Text.AlignHCenter
                }

                // Carousel below title (centered)
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 0.5
                    height: parent.height

                    CarouselView {
                        id: carouselCentered
                        anchors.fill: parent
                        gameImages: mainWindow.gameImages
                    }
                }
            }

            // Row container for left and right sections (when wiper images exist)
            Row {
                id: newReleasesRow
                visible: newReleasesArea.hasWiperImages
                anchors.fill: parent
                spacing: 20

                // Left side: NEW RELEASES title + Carousel (vertical layout)
                Item {
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height

                    Item {
                        anchors.fill: parent

                        // NEW RELEASES Title
                        Text {
                            id: newReleasesTitle
                            anchors.top: parent.top
                            anchors.topMargin: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: configManager.helloSpinText
                            font.pixelSize: 36
                            font.weight: Font.Normal
                            font.family: "Open Sans"
                            color: mainWindow.textColor
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Carousel below title
                        CarouselView {
                            id: carousel
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            gameImages: mainWindow.gameImages
                        }
                    }
                }

                // Right side: WindshieldWiper animation
                Item {
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height

                    WindshieldWiperImages {
                        id: wiperImages
                        anchors.fill: parent
                        leftImageSource: configManager.helloShow1 ? "file:" + configManager.helloShow1 : ""
                        rightImageSource: configManager.helloShow2 ? "file:" + configManager.helloShow2 : ""
                        carouselIndex: carousel.currentIndex
                    }
                }
            }
        }

        // Hours and Players row
        Row {
            id: statsRow
            anchors.top: newReleasesArea.bottom
            anchors.topMargin: 40// Balanced spacing - closer than original but not too tight
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            height: Math.min(parent.height * 0.55, 850)
            spacing: 30

            // LAB HOURS (left side)
            Item {
                width: (parent.width - parent.spacing) / 2
                height: parent.height

                HoursDisplay {
                    id: hoursDisplay
                    anchors.fill: parent
                    scheduleData: dataManager.facilityData
                    textColor: mainWindow.textColor
                    accentColor: mainWindow.hoverColor
                    titleText: configManager.helloHourText
                }
            }

            // PLAYERS (right side)
            Item {
                width: (parent.width - parent.spacing) / 2
                height: parent.height

                PlayerStats {
                    id: playerStats
                    anchors.fill: parent
                    playerData: dataManager.userData
                    platformList: configManager.platformList
                    textColor: mainWindow.textColor
                    accentColor: mainWindow.hoverColor
                    titleText: configManager.helloListText
                }
            }
        }

        // GameLab animated GIF logo at bottom left
        AnimatedImage {
            id: gameLabLogo
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: -30
            anchors.leftMargin: 40
            width: 225
            height: 225
            source: configManager.helloLogo ? "file:" + configManager.helloLogo : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            playing: true
            visible: source !== ""
        }

        // QR Code at bottom right (if available)
        Image {
            id: qrCode
            visible: configManager.helloScan !== ""
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 120
            anchors.rightMargin: 0
            width: 350
            height: 500
            source: visible && configManager.helloScan ? "file:" + configManager.helloScan : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
        }
    }

    // Data update animations
    Connections {
        target: dataManager

        function onUserDataChanged() {
            playerStats.opacity = 0
            opacityAnimation.start()
        }

        function onFacilityDataChanged() {
            hoursDisplay.opacity = 0
            opacityAnimation.start()
        }
    }

    // Config update handler
    Connections {
        target: configManager

        function onConfigChanged() {
            console.log("Config changed, reloading UI...")

            // Update game images array
            mainWindow.gameImages = [
                configManager.helloSpinImg1,
                configManager.helloSpinImg2,
                configManager.helloSpinImg3,
                configManager.helloSpinImg4
            ]

            // Force reload all images
            var oldBannerSource = bannerImage.source
            bannerImage.source = ""
            Qt.callLater(function() {
                bannerImage.source = configManager.helloLead ? "file:" + configManager.helloLead : ""
            })

            // Force reload facility logo
            logo.sourceComponent = null
            Qt.callLater(function() {
                logo.sourceComponent = configManager.helloMain.endsWith(".gif") ? animatedLogoComponent : staticLogoComponent
            })

            // Force reload wiper images
            wiperImages.leftImageSource = ""
            wiperImages.rightImageSource = ""
            Qt.callLater(function() {
                wiperImages.leftImageSource = configManager.helloShow1 ? "file:" + configManager.helloShow1 : ""
                wiperImages.rightImageSource = configManager.helloShow2 ? "file:" + configManager.helloShow2 : ""
            })

            // Force reload GameLab logo
            var oldGameLabSource = gameLabLogo.source
            gameLabLogo.source = ""
            Qt.callLater(function() {
                gameLabLogo.source = configManager.helloLogo ? "file:" + configManager.helloLogo : ""
            })

            // Force reload QR code
            var oldQRSource = qrCode.source
            qrCode.source = ""
            Qt.callLater(function() {
                qrCode.source = configManager.helloScan ? "file:" + configManager.helloScan : ""
            })
        }
    }

    // Fade in animation for data updates
    NumberAnimation {
        id: opacityAnimation
        targets: [playerStats, hoursDisplay]
        property: "opacity"
        to: 1.0
        duration: 500
        easing.type: Easing.InOutQuad
    }

    // Timer App Layer (conditionally visible)
    TimerApp {
        id: timerApp
        anchors.fill: parent
        visible: configManager.layer0 === "app_timer"
        z: visible ? 100 : -1

        timerState: configManager.timerState
        timerCount: configManager.timerCount
        timerMax: configManager.timerMax
        timerText: configManager.timerText
        timerMenuLeft: configManager.timerMenuLeft
        timerMenuMiddle: configManager.timerMenuMiddle
        timerMenuRight: configManager.timerMenuRight
        colorMain: configManager.colorMain
        colorBg01: configManager.colorBg01
        colorBg02: configManager.colorBg02
        colorText: configManager.colorText
    }

    // Custom Cursor (always on top)
    CustomCursor {
        id: customCursor
        anchors.fill: parent
        z: 10000
        enabled: configManager.renderMouse === 1
    }
}
