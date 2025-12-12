import QtQuick
import QtQuick.Controls

// Welcome App (app_hello) - Can be loaded on any layer
Item {
    id: root
    anchors.fill: parent

    // Access to parent window properties
    property var mainWindow: parent
    property bool usePixmapScrolling: mainWindow && mainWindow.usePixmapScrolling ? mainWindow.usePixmapScrolling : true
    property var gameImages: mainWindow && mainWindow.gameImages ? mainWindow.gameImages : []
    property string primaryColor: configManager.colorBg01
    property string accentColor: configManager.colorBg02
    property string textColor: configManager.colorText
    property string hoverColor: configManager.colorMain

    // Background with gradient using facility colors
    Rectangle {
        anchors.fill: parent
        z: -1  // Behind all content in this app
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.primaryColor }
            GradientStop { position: 1.0; color: root.accentColor }
        }
    }

    // Top scrolling banner (switchable between fade carousel and pixmap scrolling)
    Loader {
        id: topScroll
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.min(50, parent.height * 0.08)

        sourceComponent: root.usePixmapScrolling ? pixmapTopScroll : fadeTopScroll

        Component {
            id: fadeTopScroll
            ScrollingText {
                text: configManager.helloNews1
                textColor: root.textColor
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
                textColor: root.textColor
                lineColor: root.hoverColor
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
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.min(sourceSize.height > 0 ? sourceSize.height : 60, parent.height * 0.1)
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
        height: Math.min(50, parent.height * 0.08)

        sourceComponent: root.usePixmapScrolling ? pixmapBottomScroll : fadeBottomScroll

        Component {
            id: fadeBottomScroll
            ScrollingText {
                text: configManager.helloNews2
                textColor: root.textColor
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
                textColor: root.textColor
                lineColor: root.hoverColor
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

    // Logo area: Responsive sizing for 1024x600 base resolution
    // Scales proportionally for larger resolutions
    Item {
        id: logoContainer
        anchors.top: bannerImage.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width * 0.9, 1080)
        height: Math.min(200, parent.height * 0.25)

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
        anchors.topMargin: 10
        anchors.bottom: bottomScroll.top
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right

        // NEW RELEASES section: Carousel on left (vertical with title), WindshieldWiper on right
        Item {
            id: newReleasesArea
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9
            height: Math.min(parent.height * 0.35, 250)

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
                    color: root.textColor
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
                        gameImages: root.gameImages
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
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Carousel below title
                        CarouselView {
                            id: carousel
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            gameImages: root.gameImages
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
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            height: Math.min(parent.height * 0.5, 200)
            spacing: 20

            // LAB HOURS (left side)
            Item {
                width: (parent.width - parent.spacing) / 2
                height: parent.height

                HoursDisplay {
                    id: hoursDisplay
                    anchors.fill: parent
                    scheduleData: dataManager.facilityData
                    textColor: root.textColor
                    accentColor: root.hoverColor
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
                    textColor: root.textColor
                    accentColor: root.hoverColor
                    titleText: configManager.helloListText
                }
            }
        }

        // GameLab animated GIF logo at bottom left
        AnimatedImage {
            id: gameLabLogo
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 0
            anchors.leftMargin: 20
            width: Math.min(150, parent.width * 0.15)
            height: Math.min(150, parent.width * 0.15)
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
            anchors.bottomMargin: 20
            anchors.rightMargin: 20
            width: Math.min(200, parent.width * 0.2)
            height: Math.min(280, parent.height * 0.3)
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
            console.log("Config changed, reloading Welcome App UI...")

            // Update game images array
            root.gameImages = [
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
}
