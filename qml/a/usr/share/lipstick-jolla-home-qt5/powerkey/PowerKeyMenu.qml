import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import Sailfish.Ambience 1.0
import Sailfish.Gallery 1.0
import org.nemomobile.thumbnailer 1.0
import org.nemomobile.lipstick 0.1
import org.nemomobile.dbus 2.0
import com.jolla.lipstick 0.1
import org.freedesktop.contextkit 1.0
import org.nemomobile.notifications 1.0 as SystemNotifications

SilicaListView {
    id: powerMenu

    property real itemHeight: Screen.sizeCategory >= Screen.Large
        ? Theme.itemSizeExtraLarge + (2 * Theme.paddingLarge)
        : Math.floor((Screen.height - bottomStackHeight) / 5)
    property int itemCount: 5
    property int stackCount: 4

    readonly property bool largeScreen: Screen.sizeCategory >= Screen.Large
    readonly property real exposure: currentItem
            ? Lipstick.compositor.powerKeyLayer.absoluteExposure + currentItem.height - itemHeight
            : Lipstick.compositor.powerKeyLayer.absoluteExposure
    readonly property real stackedItemHeight: Theme.paddingSmall
    readonly property real bottomStackHeight: Math.max(0, stackedItemHeight*Math.min((powerMenu.count-itemCount+1), stackCount))

    property real contextMenuProgress

    implicitWidth: 4 * Theme.itemSizeExtraLarge
    implicitHeight: itemHeight * Math.min(itemCount, powerMenu.count + 1) + bottomStackHeight

    boundsBehavior: Flickable.StopAtBounds
    clip: count > itemCount-1
    interactive: contentHeight > implicitHeight
    displayMarginEnd: itemHeight * stackCount

    readonly property bool exposed: Lipstick.compositor.powerKeyLayer.exposed
    onExposedChanged: {
        if (!exposed) {
            positionViewAtBeginning()
        }
    }

    model: AmbienceInstallModel {
        id: installModel

        source: Lipstick.compositor.ambiences

        onAmbienceInstalling: {
            ambiencePreviewNotification.previewSummary = displayName
            ambiencePreviewNotification.previewBody = coverImage
            // Give some time for the TOH dialog to fade out
            ambiencePreviewTimer.restart()
        }

        onAmbienceInstalled: {
            Lipstick.compositor.wallpaper.setAmbience(index)
        }
    }

    Timer {
        id: ambiencePreviewTimer
        interval: 200
        onTriggered: ambiencePreviewNotification.publish()
    }

    QtObject {
        id: profile
        property string icon
        property string description
        property int timeout: 0
    }

    SystemNotifications.Notification {
        id: ambiencePreviewNotification
        category: "x-jolla.ambience.preview"
    }

    header: Item {
        id: headerItem

        width: powerMenu.width
        height: powerMenu.itemHeight
        z: powerMenu.count+1

        clip: powerTransition.running

        states: [
            State {
               name: "no-power"
               when: Lipstick.compositor.powerKeyLayer.active && !shutdownButton.visible
            }, State {
                name: "power"
                when: shutdownButton.visible
                PropertyChanges {
                    target: lockButton
                    offset: -lockButton.height
                }
            }
        ]
        transitions: Transition {
            id: powerTransition
            from: "no-power"
            to: "power"
            NumberAnimation {
                target: lockButton
                property: "offset"
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        Wallpaper {
            anchors.fill: shutdownButton
            horizontalOffset: powerMenu.x
        }

        PowerButton {
            id: shutdownButton

            width: powerMenu.width
            height: powerMenu.itemHeight

            offset: lockButton.offset + height

            clip: powerTransition.running
            visible: Lipstick.compositor.powerKeyPressed

            onClicked: dsmeDbus.call("req_shutdown", [])

            iconSource: "image://theme/graphic-power-off"

            opacity: Math.max(0.0, Math.min(1.0,
                        (powerMenu.exposure - headerItem.y + powerMenu.contentY)
                        / headerItem.height))
        }

        PowerButton {
            id: lockButton

            width: powerMenu.width
            height: powerMenu.itemHeight

            clip: powerTransition.running
            visible: !shutdownButton.visible || powerTransition.running

            onClicked: Lipstick.compositor.setDisplayOff()

            iconSource: "image://theme/graphic-display-blank"

            opacity: shutdownButton.opacity
        }
    }

    delegate: Item {
        id: ambienceItem

        property alias down: listItem.down
        property alias highlightedColor: listItem.highlightedColor

        readonly property real bottomY:  y - powerMenu.contentY + height

        property bool active: Ambience.source == url
        onActiveChanged: {
            if (active) {
                selectionHighlight.parent = listItem
            } else if (selectionHighlight.parent == listItem) {
                selectionHighlight.parent = null
            }
        }

        width: listItem.width
        height: listItem.height

        enabled: !installing
        z: powerMenu.count - index

        clip: powerMenu.exposure < powerMenu.itemHeight*stackCount

        ListItem {
            id: listItem

            y: Math.min(powerMenu.contextMenuProgress * (itemHeight-stackedItemHeight) + powerMenu.exposure
                        - (index >= itemCount-1 ? (Math.min(powerMenu.count, itemCount+stackCount-1)-index-1)*stackedItemHeight : 0), ambienceItem.bottomY)
               - ambienceItem.bottomY

            width: powerMenu.width
            contentHeight: powerMenu.itemHeight

            baselineOffset: displayNameLabel.y + (displayNameLabel.height / 2)

            highlighted: false
            highlightedColor: highlightBackgroundColor != undefined
                        ? highlightBackgroundColor
                        : Theme.highlightBackgroundColor

            onPressed: powerMenu.currentIndex = index
            onClicked: {
                Lipstick.compositor.wallpaper.setAmbience(index)
                Lipstick.compositor.powerKeyLayer.hide()
            }

            menu: Component {
                ContextMenu {
                    id: contextMenu

                    x: 0
                    MenuItem {
                        //% "Remove from favorites"
                        text: qsTrId("lipstick-jolla-home-me-unfavorite")
                        onClicked: Lipstick.compositor.ambiences.setProperty(powerMenu.currentIndex, "favorite", false)
                    }

                    onHeightChanged: if (_open) powerMenu.contextMenuProgress = height/_getDisplayHeight()
                    on_OpenChanged: if (!_open) powerMenu.contextMenuProgress = 0.0
                }
            }

            Thumbnail {
                anchors.fill: parent
                sourceSize { width: width; height: height }

                source: wallpaperUrl != undefined ? wallpaperUrl : ""

                onStatusChanged: {
                    if (status == Thumbnail.Error) {
                        errorLabelComponent.createObject(thumbnail)
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    color: Qt.darker(highlightedColor)
                    opacity: Math.max(0, Math.min(0.4, 0.4 - 3*(ambienceItem.height+listItem.y-stackedItemHeight) / ambienceItem.height))
                }
            }

            Loader {
                anchors.fill: parent
                source: installing ? "AmbienceInstallPlaceholder.qml" : ""
            }

            Rectangle {
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0.0 ,0.0, 0.0, 0.5) }
                }
                opacity: Math.max(0, 2*(ambienceItem.height+listItem.y-stackedItemHeight) / ambienceItem.height)

                Image {
                    id: contextIcon

                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium

                    source: profile.icon != ""
                            ? "image://theme/" + profile.icon
                            : ""

                    anchors {
                        left: displayNameLabel.left
                        bottom: displayNameLabel.top
                        bottomMargin: Theme.paddingMedium
                    }
                }

                Text {
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    textFormat: Text.PlainText

                    text: profile.description

                    anchors {
                        left: contextIcon.right
                        leftMargin: Theme.paddingMedium
                        baseline: contextIcon.bottom
                    }
                }

                Label {
                    id: displayNameLabel
                    anchors {
                        left: parent.left
                        leftMargin: Theme.paddingLarge
                        right: durationIndicator.visible ? durationIndicator.left : parent.right
                        rightMargin: durationIndicator.visible ? Theme.paddingMedium : Theme.paddingLarge
                        bottom: parent.bottom
                        bottomMargin: Theme.paddingMedium
                    }
                    font.pixelSize: Theme.fontSizeLarge
                    horizontalAlignment: Text.AlignLeft
                    text: displayName
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Elide
                    color: highlightColor != undefined ? highlightColor : Theme.highlightColor
                }

                Rectangle {
                    id: durationIndicator

                    width: Theme.itemSizeExtraLarge
                    height: Theme.itemSizeExtraLarge

                    visible: profile.timeout > 0

                    anchors {
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }

                    color: Theme.rgba(highlightColor != undefined ? highlightColor : Theme.highlightColor, 0.3)

                    Text {
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeHuge
                        textFormat: Text.PlainText

                        anchors.centerIn: durationIndicator

                        text: {
                            if (profile.timeout >= 60) {
                                return Math.floor(profile.timeout / 60) + "H"
                            } else if (profile.timeout > 0) {
                                return profile.timeout + "M"
                            } else {
                                return ""
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        readonly property bool highlighting: powerMenu.currentItem && powerMenu.currentItem.down

        parent: powerMenu.contentItem
        anchors.fill: powerMenu.currentItem

        visible: highlighting || highlightAnimation.running
        opacity: highlighting ? 0.5 : 0.0
        Behavior on opacity { FadeAnimation { id: highlightAnimation; duration: 100 } }

        color: powerMenu.currentItem ? powerMenu.currentItem.highlightedColor : "transparent"
        z: 2
    }

    VerticalScrollDecorator {}

    Item {
        id: selectionHighlight

        parent: null
        width: selectionGraphic.width / 2
        height: selectionGraphic.height
        anchors {
            verticalCenter: parent ? parent.baseline : undefined
            left: parent ? parent.left : undefined
        }

        GlassItem {
            id: selectionGraphic

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.left
            }

            color: Theme.primaryColor
            radius: 0.22
            falloffRadius: 0.18
            clip: true
        }
    }
    DBusInterface {
        id: dsmeDbus
        bus: DBus.SystemBus
        service: "com.nokia.dsme"
        path: "/com/nokia/dsme/request"
        iface: "com.nokia.dsme.request"
    }

    Component {
        id: errorLabelComponent
        Label {
            //: Thumbnail Image loading failed
            //% "Oops, can't display the thumbnail!"
            text: qsTrId("lipstick-jolla-home-la-image-thumbnail-loading-failed")
            anchors.centerIn: parent
            width: parent.width - 2 * Theme.paddingMedium
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
