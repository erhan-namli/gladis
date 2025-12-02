import QtQuick
import QtQuick.Window
import "Components"

Window {
    id: mainWindow
    visible: true
    visibility: Window.FullScreen
    // 9:16 aspect ratio - 1080p (1080x1920) or 4K (2160x3840)
    width: 1080
    height: 1920
    title: "GameLab Esports Dashboard"
    color: "#333333"

    // Detect orientation
    property bool isPortrait: height > width

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

    // Color properties from facility_colors
    property string primaryColor: dataManager.facilityColors["--primary_gradient_color"] || "#002657"
    property string accentColor: dataManager.facilityColors["--accent_gradient_color"] || "#00529b"
    property string textColor: dataManager.facilityColors["--text_color"] || "#fb6502"
    property string hoverColor: dataManager.facilityColors["--hover_color"] || "#ffffff"

    // Game images array
    property var gameImages: [
        dataManager.getGameImagePath(1),
        dataManager.getGameImagePath(2),
        dataManager.getGameImagePath(3),
        dataManager.getGameImagePath(4)
    ]

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
                text: dataManager.scrollUpperText
                textColor: mainWindow.textColor  // Orange text
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
                text: dataManager.scrollUpperText
                textColor: mainWindow.textColor  // Orange text
                lineColor: mainWindow.hoverColor  // White line
                backgroundColor: "#1a1a1a"
                textSize: 40
                showBottomLine: true
                scrollSpeed: 100  // Adjust for smooth horizontal scrolling
                textSpacing: 150  // Space between text repeats
                enableMotionBlur: false  // Disabled - test if shader was causing issues
                motionBlurRadius: 4  // Subtle blur effect
            }
        }
    }

    // Stationary banner image
    Image {
        id: bannerImage
        anchors.top: topScroll.bottom
        anchors.topMargin: 40  // Move down 40px
        anchors.left: parent.left
        anchors.right: parent.right
        height: sourceSize.height > 0 ? sourceSize.height : 60
        source: dataManager.getBannerImagePath()
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
                text: dataManager.scrollLowerText
                textColor: mainWindow.textColor  // Orange text
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
                text: dataManager.scrollLowerText
                textColor: mainWindow.textColor  // Orange text
                lineColor: mainWindow.hoverColor  // White line
                backgroundColor: "#1a1a1a"
                textSize: 40
                showTopLine: true
                scrollSpeed: 100  // Adjust for smooth horizontal scrolling
                textSpacing: 150  // Space between text repeats
                enableMotionBlur: false  // Disabled - test if shader was causing issues
                motionBlurRadius: 4  // Subtle blur effect
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
                    source: dataManager.getFacilityLogoPath()
                    // If image is smaller than container, don't scale up (use actual size)
                    // If image is larger, scale down to fit
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
                    source: dataManager.getFacilityLogoPath()
                    // If image is smaller than container, don't scale up (use actual size)
                    // If image is larger, scale down to fit
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

            property bool hasWiperImages: dataManager.getLeftImagePath() !== "" && dataManager.getRightImagePath() !== ""

            // Centered layout when wiper images are missing
            Item {
                visible: !newReleasesArea.hasWiperImages
                anchors.fill: parent

                // NEW RELEASES Title
                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: dataManager.textRound
                    font.pixelSize: 36
                    font.weight: Font.Normal
                    font.family: "Open Sans"
                    color: mainWindow.textColor  // Orange text
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
                            text: dataManager.textRound
                            font.pixelSize: 36
                            font.weight: Font.Normal
                            font.family: "Open Sans"
                            color: mainWindow.textColor  // Orange text
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
                        leftImageSource: dataManager.getLeftImagePath()
                        rightImageSource: dataManager.getRightImagePath()
                        carouselIndex: carousel.currentIndex  // Sync with carousel rotation
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
                    textColor: mainWindow.textColor  // Orange text
                    accentColor: mainWindow.hoverColor  // White boxes/lines
                    titleText: dataManager.textDaily
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
                    textColor: mainWindow.textColor  // Orange text
                    accentColor: mainWindow.hoverColor  // White boxes/lines
                    titleText: dataManager.textCount
                }
            }
        }

        // GameLab animated GIF logo at bottom left
        AnimatedImage {
            id: gameLabLogo
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: -30  // Moved down from 20 to 60
            anchors.leftMargin: 40
            width: 225
            height: 225
            source: dataManager.getGameLabGifPath()
            fillMode: Image.PreserveAspectFit
            smooth: true
            playing: true
            visible: source !== ""
        }

        // QR Code at bottom right (if available)
        Image {
            id: qrCode
            visible: dataManager.qrCodeAvailable
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 120
            anchors.rightMargin: 0
            width: 350
            height: 500
            source: visible ? dataManager.getQRCodePath() : ""
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

        function onImagesChanged() {
            // Force reload all images by updating the game images array
            console.log("Images changed, reloading...")
            mainWindow.gameImages = [
                dataManager.getGameImagePath(1),
                dataManager.getGameImagePath(2),
                dataManager.getGameImagePath(3),
                dataManager.getGameImagePath(4)
            ]

            // Force reload facility logo by triggering loader refresh
            logo.sourceComponent = null
            Qt.callLater(function() {
                logo.sourceComponent = dataManager.facilityLogoIsGif ? animatedLogoComponent : staticLogoComponent
            })

            // Force reload banner image
            var oldBannerSource = bannerImage.source
            bannerImage.source = ""
            Qt.callLater(function() {
                bannerImage.source = dataManager.getBannerImagePath()
            })

            // Force reload wiper images
            wiperImages.leftImageSource = ""
            wiperImages.rightImageSource = ""
            Qt.callLater(function() {
                wiperImages.leftImageSource = dataManager.getLeftImagePath()
                wiperImages.rightImageSource = dataManager.getRightImagePath()
            })

            // Force reload QR code
            if (qrCode.visible) {
                var oldQRSource = qrCode.source
                qrCode.source = ""
                Qt.callLater(function() {
                    qrCode.source = dataManager.getQRCodePath()
                })
            }
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
