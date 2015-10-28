import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Page {
    id: page
    property var widgets: ["lock","shutdown","reboot","lipstick","profile","screenshot"]
    property var names: ["Lock","Shutdown","Reboot","Restart HS","Change Profile","Screenshot"]

    ConfigurationGroup {
        id: powermenuSettings
        path: "/desktop/lipstick-jolla-home-qt5/custompowerkey/settings"
        property bool lockLabels: true
        property bool powerLabels: true
        property variant lockArray: ["lock"]
        property variant powerArray: ["shutdown"]
        property variant quickOrder: [0]
        property real lockInterval: 1
        property real quickPower: 0
        property real powerInterval: 1
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
                text: "Power Menu"
                color: Theme.highlightColor
            }

            Row {
                width: parent.width
                ComboBox {
                    id: powerCombo
                    width: parent.width - button.width
                    label: "Add:"
                    currentIndex: widgets.indexOf(powermenuSettings.powerArray[0])
                    menu: ContextMenu {
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
                            var powerArray = powermenuSettings.powerArray
                            if ( powerArray.length < 5 ) {
                                powerArray.push(widgets[powerCombo.currentIndex])
                                powermenuSettings.powerArray = powerArray
                            }
                        }
                    }
                }
            }

            property variant powerArray: powermenuSettings.powerArray
            onPowerArrayChanged: {
                powerModel.clear()
                for ( var i = 0; i < powerArray.length; i++) {
                    powerModel.append({
                                          "itemType": powermenuSettings.powerArray[i]
                                      })
                }
            }

            ListModel {
                id: powerModel
            }

            Row {
                id: row
                width: 540
                height: 180
                Repeater {
                    model: powerModel
                    delegate: SettingsPowerButton {
                        width: 540 / powerModel.count
                        height: 180
                        type: itemType
                        labelVisible: powermenuSettings.powerLabels
                    }
                }
            }

            Row {
                id: deleteRow
                Repeater {
                    model: powerModel.count
                    delegate: Image {
                        width: 540 / powerModel.count
                        fillMode: Image.PreserveAspectFit
                        source: mouseArea.pressed
                                ? "image://theme/icon-m-clear" + "?" + Theme.highlightColor
                                : "image://theme/icon-m-clear"
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                var powerArray = powermenuSettings.powerArray
                                powerArray.splice(index,1)
                                //var quickPower = powermenuSettings.quickPower
                                if ( powermenuSettings.quickPower === index ) {
                                    powermenuSettings.quickPower = -1
                                } else if ( powermenuSettings.quickPower > index ) {
                                    powermenuSettings.quickPower--
                                }
                                //powermenuSettings.quickPower = quickPower
                                powermenuSettings.powerArray = powerArray
                            }
                        }
                    }
                }
            }

            Label {
                x: Theme.paddingLarge
                text: "Quick Button"
                color: Theme.highlightColor
            }

            Row {
                id: quickRow
                height: deleteRow.height
                Repeater {
                    model: powerModel.count
                    delegate: Image {
                        width: 540 / powerModel.count
                        height: deleteRow.height
                        fillMode: Image.PreserveAspectFit
                        source: mouseArea.pressed
                                ? "image://theme/graphic-gesture-hint" + "?" + Theme.highlightColor
                                : "image://theme/graphic-gesture-hint"
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                if ( powermenuSettings.quickPower !== index ) {
                                    powermenuSettings.quickPower = index
                                } else {
                                    powermenuSettings.quickPower = -1
                                }
                            }
                        }
                        Image {
                            anchors.centerIn: parent
                            z: -1
                            source: mouseArea.pressed
                                    ? "image://theme/icon-m-dot" + "?" + Theme.highlightColor
                                    : "image://theme/icon-m-dot"
                            visible: powermenuSettings.quickPower === index
                        }
                    }
                }
            }

            Slider {
                width: parent.width - Theme.paddingLarge * 2
                label: "Quick Button interval"
                value: powermenuSettings.powerInterval
                minimumValue: 0.1
                maximumValue: 3
                stepSize: 0.1
                valueText: value === 1 ? value + " Second" : value + " Seconds"
                onValueChanged: powermenuSettings.powerInterval = value
            }

            TextSwitch {
                width: parent.width
                text: "Button labels"
                checked: powermenuSettings.powerLabels
                onClicked: powermenuSettings.powerLabels = checked
            }
        }
    }
}
