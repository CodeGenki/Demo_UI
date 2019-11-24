// Material Design for WPT project
// 2019 Senior Design Controls Team
// Genki Oji

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Universal 2.12
import Qt.labs.settings 1.0
import io.qt.wpt.serialport 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4

ApplicationWindow {
    id: window
    width: 1200
    height: 707
    visible: true
    title: "WPT application"

    SerialPort {
        id: serialport
    }

    QtObject {
        id: constants
        readonly property int pwm_dis: 0x10
        readonly property int pwm_en: 0x11
        readonly property int rec_dis: 0x12
        readonly property int rec_en: 0x13
        readonly property int dab_pri_dis: 0x14
        readonly property int dab_pri_en: 0x15

        readonly property int dab_freq_inc: 0x20
        readonly property int dab_freq_dec: 0x21
        readonly property int dab_freq_set: 0x22

        readonly property int dab_phs_inc: 0x28
        readonly property int dab_phs_dec: 0x29
        readonly property int dab_phs_set: 0x2a

        readonly property int i_loop_pr: 0x40
        readonly property int i_offset: 0x41
        readonly property int freq_change: 0x45 // freq change
    }

    // Dark mode XD
    //Material.theme: Material.Dark

    Settings {
        id: settings
        property string style: "Material"
    }

    Shortcut {
        sequences: ["Esc", "Back"]
        enabled: stackView.depth > 1
        onActivated: {
            stackView.pop()
            listView.currentIndex = -1
        }
    }

    Shortcut {
        sequence: "Menu"
        onActivated: optionsMenu.open()
    }

    header: ToolBar {
        Material.foreground: "black"
        Material.background: "transparent"
        Material.elevation: 0

        RowLayout {
            spacing: 20
            anchors.fill: parent

            ToolButton {
                icon.name: stackView.depth > 1 ? "back" : "drawer"
                icon.source: stackView.depth > 1 ? "icons/gallery/20x20/back.png" : "icons/gallery/20x20/drawer.png"
                onClicked: {
                    if (stackView.depth > 1) {
                        stackView.pop()
                        listView.currentIndex = -1
                    } else {
                        drawer.open()
                    }
                }
            }

            Label {
                id: titleLabel
                text: listView.currentItem ? listView.currentItem.text : "Wireless Power Transfer System Dashboard"
                font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                icon.name: "menu"
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    MenuItem {
                        text: "Settings"
                        onTriggered: settingsDialog.open()
                    }
                    MenuItem {
                        text: "About"
                        onTriggered: aboutDialog.open()
                    }
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: Math.min(window.width, window.height) / 4 * 2
        height: window.height
        interactive: stackView.depth === 1

        ListView {
            id: listView
            x: 0
            visible: true

            focus: true
            currentIndex: -1

            /*
            GroupBox {
                id: pwmControl
                title: qsTr("PWM Settings")
                width: drawer.width - 4
                x: 2
                background: Rectangle {
                    y: pwmControl.topPadding - pwmControl.bottomPadding
                    width: parent.width
                    height: parent.height - pwmControl.topPadding + pwmControl.bottomPadding
                    color: "transparent"
                    border.color: "#3ba2f5"
                    radius: 2
                }

                label: Label {
                    x: 3
                    width: pwmControl.availableWidth
                    text: pwmControl.title
                    color: "#3ba2f5"
                    elide: Text.ElideLeft
                }

                ColumnLayout {
                    width: parent.width
                    TextField {
                        id: pwmFreq
                        Layout.fillWidth: true
                        placeholderText: qsTr("PWM Frequency (Hz)")
                        Layout.preferredWidth: pwmControl.width - pwmControl.rightPadding*2
                    }
                    TextField {
                        Layout.preferredWidth: -1
                        Layout.fillWidth: true
                        placeholderText: qsTr("PWM Period (sec)")
                    }
                    Button {
                        text: "Apply"
                        onClicked: model.submit()
                        Layout.alignment: Qt.AlignRight
                        highlighted: true
                        Material.accent: Material.Blue
                    }
                }
            }
            */

            GroupBox {
                id: setup
                title: qsTr("Board Communication Setup")
                width: drawer.width - 4
                //anchors.top: pwmControl.bottom
                anchors.topMargin: 2
                x: 2
                background: Rectangle {
                    y: setup.topPadding - setup.bottomPadding
                    width: parent.width
                    height: parent.height - setup.topPadding + setup.bottomPadding
                    color: "transparent"
                    border.color: "#3ba2f5"
                    radius: 2
                }

                label: Label {
                    x: 3
                    width: setup.availableWidth
                    text: setup.title
                    color: "#3ba2f5"
                    elide: Text.ElideLeft
                }
                ColumnLayout {
                    width: parent.width
                    spacing: 5
                    Row {
                        id: row
                        height: 40
                        Layout.preferredHeight: -1
                        Layout.fillWidth: true
                        Label {
                            id: label
                            text: "Select Serial Port"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#3ba2f5"
                        }
                        ComboBox {
                            id: portName
                            width: 177
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            editable: true
                            Layout.preferredWidth: -1
                            Layout.fillWidth: true
                            model: serialport.getCOM()
                            onAccepted: {
                                if (find(editText) === -1)
                                    comModel.append({text: editText})
                            }
                        }
                    }
                    Row {
                        id: row1
                        y: 40
                        height: 40
                        Layout.fillWidth: true
                        Label {
                            text: "Baud Rate"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#3ba2f5"
                        }
                        ComboBox {
                            id: baudrate
                            width: 177
                            currentIndex: 0
                            rightPadding: 40
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            Layout.fillWidth: false
                            Layout.preferredWidth: portName.width
                            model: ListModel {
                                ListElement { text: "1000000" }
                                ListElement { text: "115200" }
                                ListElement { text: "38400" }
                                ListElement { text: "19200" }
                                ListElement { text: "9600" }
                            }
                        }
                    }
                    Row {
                        id: row2
                        y: 40
                        height: 40
                        Layout.fillWidth: true
                        Label {
                            text: "Data Bits"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#3ba2f5"
                        }
                        ComboBox {
                            id: databits
                            width: 177
                            currentIndex: 3
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            Layout.fillWidth: false
                            Layout.preferredWidth: portName.width
                            model: ListModel {
                                ListElement { text: "5" }
                                ListElement { text: "6" }
                                ListElement { text: "7" }
                                ListElement { text: "8" }
                            }
                        }
                    }
                    Row {
                        id: row3
                        y: 40
                        height: 40
                        Layout.fillWidth: true
                        Label {
                            text: "Parity"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#3ba2f5"
                        }
                        ComboBox {
                            id: parity
                            width: 177
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            Layout.fillWidth: false
                            Layout.preferredWidth: portName.width
                            model: ListModel {
                                ListElement { text: "None" }
                                ListElement { text: "Even" }
                                ListElement { text: "Odd" }
                                ListElement { text: "Mark" }
                                ListElement { text: "Space" }
                            }
                        }
                    }
                    Row {
                        id: row4
                        y: 40
                        height: 40
                        Layout.fillWidth: true
                        Label {
                            text: "Stop Bits"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#3ba2f5"
                        }
                        ComboBox {
                            id: stopbits
                            width: 177
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            Layout.fillWidth: false
                            Layout.preferredWidth: portName.width
                            model: ListModel {
                                ListElement { text: "1" }
                                ListElement { text: "1.5" }
                                ListElement { text: "2" }
                            }
                        }
                    }
                    Row {
                        id: row5
                        y: 40
                        height: 40
                        Layout.fillWidth: true
                        Label {
                            text: "Flow Control"
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#3ba2f5"
                        }
                        ComboBox {
                            id: flowcontrol
                            width: 177
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            Layout.fillWidth: false
                            Layout.preferredWidth: portName.width
                            model: ListModel {
                                ListElement { text: "None" }
                                ListElement { text: "RTS/CTS" }
                                ListElement { text: "XON/XOFF" }
                            }
                        }
                    }
                    Row {
                        id: row6
                        y: 40
                        height: 40
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        Button {
                            id: serialConnect
                            text: "Connect"
                            enabled: true
                            onClicked: {
                                serialport.openSerialPort(portName.currentText, baudrate.currentText,
                                                             databits.currentText,parity.currentText,
                                                             stopbits.currentText,flowcontrol.currentText);
                                serialConnect.enabled = false;
                                serialDisconnect.enabled = true;
                            }
                            highlighted: true
                            Material.accent: Material.Blue
                            anchors.right: serialDisconnect.left
                        }
                        Button {
                            id: serialDisconnect
                            text: "Disconnect"
                            enabled: false
                            onClicked: {
                                serialport.closeSerialPort();
                                serialConnect.enabled = true;
                                serialDisconnect.enabled = false;
                            }
                            highlighted: true
                            Material.accent: Material.Blue
                            anchors.right: parent.right
                        }
                    }
                }
            }

            GroupBox {
                id: advancedControls
                title: qsTr("Advanced Settings")
                width: drawer.width - 4
                anchors.top: setup.bottom
                anchors.topMargin: 10
                x: 2
                background: Rectangle {
                    y: advancedControls.topPadding - advancedControls.bottomPadding
                    width: parent.width
                    height: parent.height - advancedControls.topPadding + advancedControls.bottomPadding
                    color: "transparent"
                    border.color: "#3ba2f5"
                    radius: 2
                }

                label: Label {
                    x: 3
                    width: advancedControls.availableWidth
                    text: advancedControls.title
                    color: "#3ba2f5"
                    elide: Text.ElideLeft
                }

                ColumnLayout {
                    width: parent.width
                    RowLayout {
                        Label {
                            text: "Maximum Frequency"
                            Layout.preferredWidth: 250
                        }

                        TextField {
                            id: maxFreq
                            Layout.fillWidth: true
                            placeholderText: qsTr("Max Frequency (kHz)")
                            text: "200"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: "kHz"
                        }
                    }

                    RowLayout {
                        Label {
                            text: "Maximum Power"
                            Layout.preferredWidth: 250
                        }

                        TextField {
                            id: maxPow
                            Layout.fillWidth: true
                            placeholderText: qsTr("Max Power (Watts)")
                            text: "1000"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: "W"
                        }
                    }

                    Button {
                        text: "Apply"
                        onClicked: {
                            freqSlider.to = maxFreq.text
                            maxPower.text = maxPow.text
                        }

                        Layout.alignment: Qt.AlignRight
                        highlighted: true
                        Material.accent: Material.Blue
                    }

                    RowLayout{
                        id: freqRow
                        Label {
                            id: freqLabel
                            anchors.top: minPower.bottom
                            anchors.topMargin: 15
                            text: "Switching Frequency:"
                        }

                        Label {
                            id: freq
                            anchors.top: minPower.bottom
                            anchors.topMargin: 15
                            anchors.right: parent.right
                            //text: (pwmFreq.length > 0) ? pwmFreq.text + " Hz" : "N/A"
                            text: freqSlider.value + " kHz"
                            color: "#14de4a"
                        }
                    }


                    RowLayout {
                        width: parent.width
                        Slider {
                            id: freqSlider
                            x: -2
                            width: advancedControls.width - submitFreq.width
                            rightPadding: 5
                            leftPadding: 0
                            bottomPadding: 0
                            value: 0
                            from: 0
                            to: 200
                            stepSize: 1
                        }

                        Button {
                            id: submitFreq
                            text: "Submit"
                            onClicked: {
                                serialport.sendCmd(constants.freq_change,freqSlider.value,0,0);
                            }
                        }
                    }
                }
            }

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    StackView {
        id: stackView
        width: 1900
        anchors.fill: parent

        initialItem: Pane {
            id: pane

            AnimatedImage {
                id: animation
                source: "images/wpt.gif"
                width: 550
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                paused: pwmSwitch.checked ? false : true
                currentFrame: pwmSwitch.checked ? currentFrame : 0
            }

            AnimatedImage {
                id: animation1
                source: "images/Empty_Car.gif"
                anchors.left: animation.right
                anchors.leftMargin: 90
                anchors.verticalCenter: parent.verticalCenter
                width: 650
                height: 650
                fillMode: Image.PreserveAspectFit

                //paused: pwmSwitch.checked ? false : true
                currentFrame: pwmSwitch.checked ? currentFrame : 0
            }

            GroupBox {
                id: switchBox
                anchors.horizontalCenter: parent.horizontalCenter
                width: 175
                height: 73
                y: window.height*3/4

                background: Rectangle {
                    y: switchBox.topPadding - switchBox.bottomPadding
                    width: parent.width
                    height: parent.height - switchBox.topPadding + switchBox.bottomPadding
                    color: "transparent"
                    border.color: pwmSwitch.checked ? "green" : "red"
                    radius: 2
                }

                Label {
                    id: switchLabel
                    text: "Wireless Power Transfer"
                    //y: window.height*3/4
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Switch {
                    id: pwmSwitch
                    text: pwmSwitch.checked ? "Enabled" : "Disabled"
                    anchors.top: switchLabel.bottom
                    anchors.horizontalCenter: parent.horizontalCenter

                    contentItem: Text {
                        text: pwmSwitch.text
                        color: pwmSwitch.checked ? "green" : "red"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: pwmSwitch.indicator.width + pwmSwitch.spacing
                    }
                    onClicked: {
                        pwmSwitch.checked ? serialport.sendCmd(constants.pwm_en,0,0,0) : serialport.sendCmd(constants.pwm_dis,0,0,0);
                        pwmSwitch.checked ? animation1.source = "images/Charging_Car.gif" : animation1.source = "images/Empty_Car.gif";
                        //if(animation1.source == "images/Empty_Car.gif" && pwmSwitch.checked)
                            //animation1.source = "images/Charging_Car.gif";
//                        else{
//                            animation1.source = "images/Empty_Car.gif";
////                            animation1.paused = true;
//                        }
                    }
                }
            }

            GroupBox {
                id: inputBox
                title: qsTr("Inputs")
                anchors.verticalCenter: parent.verticalCenter
                width: window.width/3
                height: window.height*4/6

                background: Rectangle {
                    y: inputBox.topPadding - inputBox.bottomPadding
                    width: parent.width
                    height: parent.height - inputBox.topPadding + inputBox.bottomPadding
                    color: "transparent"
                    border.color: "#3ba2f5"
                    radius: 2
                }

                label: Label {
                    x: 3
                    width: inputBox.availableWidth
                    text: inputBox.title
                    color: "#3ba2f5"
                    elide: Text.ElideLeft
                    font.pointSize: 20
                }

                Label {
                    id: vdc
                    objectName: "Vdc"
                    text: "Charging Voltage: " + serialport.V_Dc + "V"
                    font.pointSize: 25
                }

                ProgressBar {
                    id: vdcGauge
                    width: inputBox.width - 20
                    height: 15
                    value: serialport.V_Dc
                    from: 0
                    to: 100
                    anchors.top: vdc.bottom
                    anchors.topMargin: 5

                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 6
                        color: "#e6e6e6"
                        radius: 3
                    }
                    contentItem: Item {
                        implicitWidth: 200
                        implicitHeight: 4

                        Rectangle {
                            width: vdcGauge.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: "#03d7fc"
                        }
                    }
                }

//                CircularGauge {
//                    id: vdcGauge
//                    anchors.top: vdc.bottom
//                    style: CircularGaugeStyle {
//                        needle: Rectangle {
//                            y: outerRadius * 0.15
//                            implicitWidth: outerRadius * 0.03
//                            implicitHeight: outerRadius * 0.9
//                            antialiasing: true
//                            color: Qt.rgba(0.66, 0.3, 0, 1)
//                        }
//                       tickmarkStepSize: 10
//                    }
//                    maximumValue: 100
//                    minimumValue: 0
//                    value: serialport.V_Dc
//                    stepSize: 1
//                }

                Label {
                    id: idc
                    objectName: "Vdc"
                    text: "Charging Current: " + serialport.I_Dc + "A"
                    font.pointSize: 25
                    anchors.top: vdcGauge.bottom
                    anchors.topMargin: 5
                }

                ProgressBar {
                    id: idcGauge
                    width: inputBox.width - 20
                    height: 15
                    value: serialport.I_Dc
                    from: 0
                    to: 15
                    anchors.top: idc.bottom
                    anchors.topMargin: 5

                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 6
                        color: "#e6e6e6"
                        radius: 3
                    }
                    contentItem: Item {
                        implicitWidth: 200
                        implicitHeight: 4

                        Rectangle {
                            width: idcGauge.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: "#03d7fc"
                        }
                    }
                }

                Row {

                }

                Label {
                    id: progressLabel
                    text: "Charging Power:   " + (serialport.V_Dc * serialport.I_Dc).toFixed(2) + "W"
                    anchors.top: idcGauge.bottom
                    font.pointSize: 25
                }

                CircularGauge {
                    id: powerGauge
                    anchors.top: progressLabel.bottom
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.leftMargin: (parent.width - powerGauge.width)/2
                    style: CircularGaugeStyle {
                        needle: Rectangle {
                            y: outerRadius * 0.15
                            implicitWidth: outerRadius * 0.03
                            implicitHeight: outerRadius * 0.9
                            antialiasing: true
                            color: Qt.rgba(0.66, 0.3, 0, 1)
                        }
                        tickmarkStepSize: 5
                    }
                    maximumValue: 60
                    minimumValue: 0
                    value: (serialport.V_Dc * serialport.I_Dc)
                    stepSize: 1
                }
            }
        }
    }

    Dialog {
        id: settingsDialog
        x: Math.round((window.width - width) / 2)
        y: Math.round(window.height / 6)
        width: Math.round(Math.min(window.width, window.height) / 3 * 2)
        modal: true
        focus: true
        title: "Settings"

        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            settings.style = styleBox.displayText
            settingsDialog.close()
        }
        onRejected: {
            styleBox.currentIndex = styleBox.styleIndex
            settingsDialog.close()
        }

        contentItem: ColumnLayout {
            id: settingsColumn
            spacing: 20

            RowLayout {
                spacing: 10

                Label {
                    text: "Style:"
                }

                ComboBox {
                    id: styleBox
                    property int styleIndex: -1
                    model: availableStyles
                    Component.onCompleted: {
                        styleIndex = find(settings.style, Qt.MatchFixedString)
                        if (styleIndex !== -1)
                            currentIndex = styleIndex
                    }
                    Layout.fillWidth: true
                }
            }

            Label {
                text: "Restart required"
                color: "#e41e25"
                opacity: styleBox.currentIndex !== styleBox.styleIndex ? 1.0 : 0.0
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Dialog {
        id: aboutDialog
        modal: true
        focus: true
        title: "About"
        x: (window.width - width) / 2
        y: window.height / 6
        width: Math.min(window.width, window.height) / 3 * 2
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            spacing: 20

            Label {
                width: aboutDialog.availableWidth
                text: "The Qt Quick Controls 2 module delivers the next generation user interface controls based on Qt Quick."
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }

            Label {
                width: aboutDialog.availableWidth
                text: "In comparison to the desktop-oriented Qt Quick Controls 1, Qt Quick Controls 2 "
                      + "are an order of magnitude simpler, lighter and faster, and are primarily targeted "
                      + "towards embedded and mobile platforms."
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }
        }
    }
}

















/*##^## Designer {
    D{i:18;anchors_width:352}D{i:17;anchors_x:0}D{i:14;anchors_width:352}D{i:13;anchors_x:0;invisible:true}
D{i:12;invisible:true}D{i:83;invisible:true}D{i:84;invisible:true}D{i:86;invisible:true}
D{i:85;invisible:true}D{i:82;invisible:true}D{i:87;invisible:true}D{i:78;invisible:true}
}
 ##^##*/
