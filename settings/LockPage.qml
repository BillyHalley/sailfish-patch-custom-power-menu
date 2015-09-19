import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0


Page {
    id: page
    property var widgets: ["lock","shutdown","reboot","lipstick","profile"]
    property var names: ["Lock","Shutdown","Reboot","Restart HS","Change Profile"]

    ConfigurationGroup {
        id: powermenuSettings
        path: "/desktop/lipstick-jolla-home-qt5/custompowerkey/settings"
        property bool lockLabels: true
        property bool powerLabels: true
        property variant lockArray: ["lock"]
        property variant powerArray: ["shutdown"]
        property variant quickOrder: [0]
        property real lockInterval: 1
        property int quickPower: 0
        property real powerInterval: 1
    }

    onStatusChanged: {
        if ( status === PageStatus.Active )
            pageStack.pushAttached("PowerPage.qml")
    }

    SilicaFlickable {
        anchors.fill: parent
        VerticalScrollDecorator {}
        contentHeight: column.height
        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Powermenu settings"
            }
            Label {
                x: Theme.paddingLarge
                text: "Lock Menu"
                color: Theme.highlightColor
            }

            Row {
                width: parent.width
                ComboBox {
                    id: lockCombo
                    width: parent.width - button.width
                    label: "Add:"
                    currentIndex: widgets.indexOf(powermenuSettings.lockArray[0])
                    menu: ContextMenu {
                        id: lockMenu
                        Repeater {
                            model: widgets.length
                            delegate: MenuItem {
                                text: names[index]
                            }
                        }
                    }
                }
                Image {
                    id: button
                    width: sourceSize.width * 2
                    fillMode: Image.PreserveAspectFit
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingSmall
                    source: mouseArea.pressed
                            ? "image://theme/icon-m-add" + "?" + Theme.highlightColor
                            : "image://theme/icon-m-add"
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            var lockArray = powermenuSettings.lockArray
                            if ( lockArray.length < 5 ) {
                                lockArray.push(widgets[lockCombo.currentIndex])
                                powermenuSettings.lockArray = lockArray
                            }
                        }
                    }
                }
            }

            property variant lockArray: powermenuSettings.lockArray
            onLockArrayChanged: {
                lockModel.clear()
                for ( var i = 0; i < lockArray.length; i++) {
                    lockModel.append({
                                         "itemType": powermenuSettings.lockArray[i]
                                     })
                }
            }

            ListModel {
                id: lockModel
            }

            Row {
                id: row
                width: 540
                height: 180
                Repeater {
                    model: lockModel
                    delegate: SettingsPowerButton {
                        width: 540 / lockModel.count
                        height: 180
                        type: itemType
                        labelVisible: powermenuSettings.lockLabels
                    }
                }
            }

            Row {
                id: deleteRow
                Repeater {
                    model: lockModel.count
                    delegate: Image {
                        width: 540 / lockModel.count
                        fillMode: Image.PreserveAspectFit
                        source: mouseArea.pressed
                                ? "image://theme/icon-m-clear" + "?" + Theme.highlightColor
                                : "image://theme/icon-m-clear"
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                var lockArray = powermenuSettings.lockArray
                                lockArray.splice(index,1)
                                var quickOrder = powermenuSettings.quickOrder
                                if ( quickOrder.indexOf(index) !== -1 )
                                    quickOrder.splice(quickOrder.indexOf(index),1)
                                for ( var i = 0; i < quickOrder.length; i++)
                                    if ( quickOrder[i] > index )
                                        quickOrder[i]--
                                powermenuSettings.quickOrder = quickOrder
                                powermenuSettings.lockArray = lockArray
                            }
                        }
                    }
                }
            }

            Label {
                x: Theme.paddingLarge
                text: "Quick Buttons"
                color: Theme.highlightColor
            }

            Row {
                id: quickRow
                height: deleteRow.height
                Repeater {
                    model: lockModel.count
                    delegate: Image {
                        width: 540 / lockModel.count
                        height: deleteRow.height
                        fillMode: Image.PreserveAspectFit
                        source: mouseArea.pressed
                                ? "image://theme/graphic-gesture-hint" + "?" + Theme.highlightColor
                                : "image://theme/graphic-gesture-hint"
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                if ( powermenuSettings.quickOrder.indexOf(index) === -1 ) {
                                    var quickOrder = powermenuSettings.quickOrder
                                    quickOrder[quickOrder.length] = index
                                    powermenuSettings.quickOrder = quickOrder
                                } else {
                                    var quickOrder = powermenuSettings.quickOrder
                                    quickOrder.splice(quickOrder.indexOf(index),1)
                                    powermenuSettings.quickOrder = quickOrder
                                }
                            }
                        }
                        Label {
                            anchors.centerIn: parent
                            text: powermenuSettings.quickOrder.indexOf(index) + 1
                            visible: powermenuSettings.quickOrder.indexOf(index) !== -1
                        }
                    }
                }
            }

            Slider {
                width: parent.width - Theme.paddingLarge * 2
                label: "Quick Button interval"
                value: powermenuSettings.lockInterval
                minimumValue: 0.1
                maximumValue: 3
                stepSize: 0.1
                valueText: value === 1 ? value + " Second" : value + " Seconds"
                onValueChanged: powermenuSettings.lockInterval = value
            }

            TextSwitch {
                width: parent.width
                text: "Button labels"
                checked: powermenuSettings.lockLabels
                onClicked: powermenuSettings.lockLabels = checked
            }
        }
    }
}
