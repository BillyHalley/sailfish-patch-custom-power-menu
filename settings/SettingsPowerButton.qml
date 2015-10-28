import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: button

    property string type
    property bool labelVisible

    signal click()

    visible: type !== "empty"

    property string iconSource: {
        if ( type === "shutdown" )
            "image://theme/graphic-power-off"
        else if ( type === "lock" )
            "image://theme/graphic-display-blank"
        else if ( type === "reboot" )
            "image://theme/graphic-reboot"
        else if ( type === "lipstick" )
            "/usr/share/patchmanager/patches/b-halley-custom-power-menu/icons/graphic-restart-lipstick.png"
        else if ( type === "profile" )
            "image://theme/graphic-sound-silent-off"
        else if ( type === "screenshot")
            "/usr/share/patchmanager/patches/b-halley-custom-power-menu/icons/graphic-m-screenshot.png"
        else if ( type === "app" )
            ""
        else if ( type === "empty" )
            ""
    }

    property string labelText: {
        switch ( type ) {
        case "shutdown":
            return "Shutdown"
        case "lock":
            return "Lock Screen"
        case "reboot":
            return "Reboot"
        case "lipstick":
            return "Restart HS"
        case "profile":
            return "Enable Sounds"
        case "screenshot":
            return "Screenshot"
        case "app":
            break
        case "empty":
            break
        }
    }

    property alias icon: icon
    property alias offset: content.y

    readonly property bool down: mouseArea.pressed

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked:{
            click()
        }
    }

    PauseAnimation {
        id: pressTimer
        alwaysRunToEnd: true
        running: mouseArea.pressed
        duration: 50
    }

    Rectangle {
        id: content

        width: button.width
        height: button.height
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
        Image {
            id: icon
            anchors.centerIn: parent
            source: button.down
                    ? button.iconSource + "?" + Theme.highlightColor
                    : button.iconSource

            width: Theme.iconSizeLauncher
            height: Theme.iconSizeLauncher
        }

        Label {
            id: label
            width: parent.width - Theme.paddingSmall
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            truncationMode: TruncationMode.Fade
            horizontalAlignment: contentWidth > width ? Text.AlignLeft : Text.AlignHCenter
            text: labelText
            color: Theme.secondaryColor
            visible: labelVisible
        }
    }
}
