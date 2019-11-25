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
import QtCharts 2.1

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
                text: listView.currentItem ? listView.currentItem.text : "Wireless Charging Dashboard"
                //font.pixelSize: 20
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
                font.pointSize: 36*window.width/1200
            }

            ToolButton {
                icon.name: "menu"
                icon.source: "icons/gallery/20x20/menu.png"
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    MenuItem {
                        text: "About"
                        onTriggered: aboutDialog.open()
                    }
                    MenuItem {
                        text: "Chart"
                        onTriggered: chartDialog.open()
                    }
                }
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
                text: "UT ECE Senior Design Project Spring 2019 - Fall 2019"
                wrapMode: Label.Wrap
                font.pixelSize: 12
            }

            Label {
                width: aboutDialog.availableWidth
                text: "Mark De Hoyos, Hannah Maxwell, Tariq Muhanna, Genki Oji, Robert Qian, Mark Sand"
                wrapMode: Label.Wrap
                font.pixelSize: 12
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
                            text: "200"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label {
                            text: "W"
                        }
                    }

                    Button {
                        id: applySettings
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
                        anchors.top: applySettings.bottom
                        anchors.topMargin: 15
                        Label {
                            id: freqLabel
                            text: "Switching Frequency:"
                        }
                        Label {
                            id: freq
                            anchors.right: parent.right
                            //text: (pwmFreq.length > 0) ? pwmFreq.text + " Hz" : "N/A"
                            text: freqSlider.value + " kHz"
                            color: "#14de4a"
                        }
                    }

                    Slider {
                        id: freqSlider
                        x: -2
                        width: advancedControls.width
                        anchors.top: freqRow.bottom
                        rightPadding: 5
                        leftPadding: 0
                        bottomPadding: 0
                        value: 78
                        from: 0
                        to: maxFreq.text
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

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    function loopAnim() {
        if(animation.source == "qrc:/images/loop.gif" && animation.currentFrame > 98)
            animation.currentFrame = 23;
    }

    function sourceChange() {
        animation.currentFrame = 0;
        animation.paused = false;
        animation.playing = true;
    }

    function getBezierCurve(name)
    {
        if (name === "Easing.Bezier")
            return easingCurve;
        return [];
    }

    function returnToStartPos(){
        if(animation1.x == window.width)
            animation1.state = "OFF_SCREEN";
        if(animation1.x == -1*animation1.width){
            animation1.source = "qrc:/images/Empty_Car.gif";
            animation1.state = "OFF_LEFT";
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
                source: "images/start.gif"
                width: 650*window.width/1200
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                x: window.width*7/10 - animation.width/2
                //anchors.horizontalCenter: parent.horizontalCenter
                onCurrentFrameChanged: loopAnim();
                onSourceChanged: sourceChange()
            }

            AnimatedImage {
                id: animation1
                source: "images/Empty_Car.gif"
                anchors.bottom: animation.top
                anchors.bottomMargin: -100*window.width/1200
                x: 0;
                width: 300*window.width/1200
                fillMode: Image.PreserveAspectFit

                currentFrame: pwmSwitch.checked ? currentFrame : 0
                onXChanged: returnToStartPos()

                state: "OFF_LEFT"
                property var easingCurve: [ 0.2, 0.2, 0.13, 0.65, 0.2, 0.8,
                                            0.624, 0.98, 0.93, 0.95, 1, 1 ]
                states: [
                    State {
                        name: "CENTERED"
                        PropertyChanges {
                            target: animation1;
                            x: window.width*7/10 - animation1.width/2
                        }
                    },
                    State {
                        name: "OFF_RIGHT"
                        PropertyChanges {
                            target: animation1;
                            x: window.width
                        }
                    },
                    State {
                        name: "OFF_LEFT"
                        PropertyChanges {
                            target: animation1;
                            x: 0
                        }
                    },
                    State {
                        name: "OFF_SCREEN"
                        PropertyChanges {
                            target: animation1;
                            x: -1*animation1.width
                        }
                    }

                ]
                transitions: [
                    Transition {
                        from: "OFF_LEFT"
                        to: "CENTERED"
                        NumberAnimation {
                            properties: "x";
                            duration: 1000;
                            easing.type: Easing.OutQuad;
                            easing.bezierCurve: getBezierCurve("Easing.OutQuad");
                        }
                    },
                    Transition {
                        from: "CENTERED"
                        to: "OFF_RIGHT"
                        NumberAnimation {
                            properties: "x";
                            duration: 1000;
                            easing.type: Easing.InQuad;
                            easing.bezierCurve: getBezierCurve("Easing.InQuad");
                        }
                    },
                    Transition {
                        from: "OFF_SCREEN"
                        to: "OFF_LEFT"
                        NumberAnimation {
                            properties: "x";
                            duration: 750;
                            easing.type: Easing.InQuad;
                            easing.bezierCurve: getBezierCurve("Easing.InQuad");
                        }
                    }
                ]
            }

            GroupBox {
                id: switchBox
                //anchors.horizontalCenter: parent.horizontalCenter
                width: 250*window.width/1200
                height: width*0.4
                anchors.bottom: inputBox.bottom
                x: window.width*7/10 - width/2

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
                    //text: "Wireless Power Transfer"
                    text: "Wireless Charger"
                    //y: window.height*3/4
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 20*window.width/1200
                }

                Switch {
                    id: pwmSwitch
                    text: pwmSwitch.checked ? "ON" : "OFF"
                    anchors.top: switchLabel.bottom
                    anchors.topMargin: inputBox.height*0.02
                    anchors.horizontalCenter: parent.horizontalCenter

                    contentItem: Text {
                        text: pwmSwitch.text
                        color: pwmSwitch.checked ? "green" : "red"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: pwmSwitch.indicator.width + pwmSwitch.spacing
                        font.pointSize: 13*window.width/1200
                    }

                    indicator: Rectangle {
                        implicitWidth: 48*window.width/1200
                        implicitHeight: 26*implicitWidth/48
                        x: pwmSwitch.leftPadding
                        y: parent.height / 2 - height / 2
                        radius: 13*implicitWidth/48
                        color: pwmSwitch.checked ? "#17a81a" : "#ffffff"
                        border.color: pwmSwitch.checked ? "#17a81a" : "#cccccc"

                        Rectangle {
                            x: pwmSwitch.checked ? parent.width - width : 0
                            width: parent.implicitHeight
                            height: parent.implicitHeight
                            radius: parent.radius
                            color: pwmSwitch.down ? "#cccccc" : "#ffffff"
                            border.color: pwmSwitch.checked ? (pwmSwitch.down ? "#17a81a" : "#21be2b") : "#999999"
                        }
                    }

                    onClicked: {
                        pwmSwitch.checked ? serialport.sendCmd(constants.pwm_en,0,0,0) : serialport.sendCmd(constants.pwm_dis,0,0,0);
                        pwmSwitch.checked ? animation1.source = "images/Charging_Car.gif" : animation1.source = "images/Charged_Car.gif";
                        pwmSwitch.checked ? animation.source = "images/loop.gif" : animation.source = "images/end.gif";
                        pwmSwitch.checked ? animation1.state = "CENTERED" : animation1.state = "OFF_RIGHT";
                    }
                }
            }

            GroupBox {
                id: inputBox
                title: qsTr("Inputs")
                //anchors.verticalCenter: parent.verticalCenter
                y: window.height*1/6 + 5
                width: window.width*2/5
                height: window.height*6/9

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
                    font.pointSize: 20*window.width/1200
                }

                Label {
                    id: vdc
                    objectName: "Vdc"
                    text: "Charging Voltage: " + serialport.V_Dc + "V"
                    font.pointSize: 22*window.width/1200
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
                    font.pointSize: 22*window.width/1200
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
                    font.pointSize: 22*window.width/1200
                }

                CircularGauge {
                    id: powerGauge
                    value: (serialport.V_Dc * serialport.I_Dc)
                    anchors.top: progressLabel.bottom
                    anchors.topMargin: 5*window.height/707
                    anchors.left: parent.left
                    anchors.leftMargin: (parent.width - powerGauge.width)/2
                    maximumValue: maxPow.text
                    minimumValue: 0
                    // We set the width to the height, because the height will always be
                    // the more limited factor. Also, all circular controls letterbox
                    // their contents to ensure that they remain circular. However, we
                    // don't want to extra space on the left and right of our gauges,
                    // because they're laid out horizontally, and that would create
                    // large horizontal gaps between gauges on wide screens.
                    width: height
                    height: parent.height * 0.6

                    style: CircularGaugeStyle {
                        tickmarkInset: toPixels(0.04)
                        minorTickmarkInset: tickmarkInset
                        labelStepSize: 20
                        labelInset: toPixels(0.23)

                        property real xCenter: outerRadius
                        property real yCenter: outerRadius
                        property real needleLength: outerRadius - tickmarkInset * 1.25
                        property real needleTipWidth: toPixels(0.02)
                        property real needleBaseWidth: toPixels(0.06)
                        property bool halfGauge: false

                        function toPixels(percentage) {
                            return percentage * outerRadius;
                        }

                        function degToRad(degrees) {
                            return degrees * (Math.PI / 180);
                        }

                        function radToDeg(radians) {
                            return radians * (180 / Math.PI);
                        }

                        function paintBackground(ctx) {
                            if (halfGauge) {
                                ctx.beginPath();
                                ctx.rect(0, 0, ctx.canvas.width, ctx.canvas.height / 2);
                                ctx.clip();
                            }

                            ctx.beginPath();
                            ctx.fillStyle = "black";
                            ctx.ellipse(0, 0, ctx.canvas.width, ctx.canvas.height);
                            ctx.fill();

                            ctx.beginPath();
                            ctx.lineWidth = tickmarkInset;
                            ctx.strokeStyle = "black";
                            ctx.arc(xCenter, yCenter, outerRadius - ctx.lineWidth / 2, outerRadius - ctx.lineWidth / 2, 0, Math.PI * 2);
                            ctx.stroke();

                            ctx.beginPath();
                            ctx.lineWidth = tickmarkInset / 2;
                            ctx.strokeStyle = "#222";
                            ctx.arc(xCenter, yCenter, outerRadius - ctx.lineWidth / 2, outerRadius - ctx.lineWidth / 2, 0, Math.PI * 2);
                            ctx.stroke();

                            ctx.beginPath();
                            var gradient = ctx.createRadialGradient(xCenter, yCenter, 0, xCenter, yCenter, outerRadius * 1.5);
                            gradient.addColorStop(0, Qt.rgba(1, 1, 1, 0));
                            gradient.addColorStop(0.7, Qt.rgba(1, 1, 1, 0.13));
                            gradient.addColorStop(1, Qt.rgba(1, 1, 1, 1));
                            ctx.fillStyle = gradient;
                            ctx.arc(xCenter, yCenter, outerRadius - tickmarkInset, outerRadius - tickmarkInset, 0, Math.PI * 2);
                            ctx.fill();
                        }

                        background: Canvas {
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                paintBackground(ctx);
                            }

                            Text {
                                id: speedText
                                font.pixelSize: toPixels(0.3)
                                text: kphInt
                                color: "white"
                                horizontalAlignment: Text.AlignRight
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.verticalCenter
                                anchors.topMargin: toPixels(0.1)

                                readonly property int kphInt: control.value
                            }
                            Text {
                                text: "Watts"
                                color: "white"
                                font.pixelSize: toPixels(0.09)
                                anchors.top: speedText.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        needle: Canvas {
                            implicitWidth: needleBaseWidth
                            implicitHeight: needleLength

                            property real xCenter: width / 2
                            property real yCenter: height / 2

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();

                                ctx.beginPath();
                                ctx.moveTo(xCenter, height);
                                ctx.lineTo(xCenter - needleBaseWidth / 2, height - needleBaseWidth / 2);
                                ctx.lineTo(xCenter - needleTipWidth / 2, 0);
                                ctx.lineTo(xCenter, yCenter - needleLength);
                                ctx.lineTo(xCenter, 0);
                                ctx.closePath();
                                ctx.fillStyle = Qt.rgba(0.66, 0, 0, 0.66);
                                ctx.fill();

                                ctx.beginPath();
                                ctx.moveTo(xCenter, height)
                                ctx.lineTo(width, height - needleBaseWidth / 2);
                                ctx.lineTo(xCenter + needleTipWidth / 2, 0);
                                ctx.lineTo(xCenter, 0);
                                ctx.closePath();
                                ctx.fillStyle = Qt.lighter(Qt.rgba(0.66, 0, 0, 0.66));
                                ctx.fill();
                            }
                        }

                        foreground: null
                    }
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

    Item {
        Text {
            id: time
            text: "0";
            visible: false
        }
        Timer {
            id: refreshTimer
            interval: 1000 // milliseconds
            running: true
            repeat: true
            onTriggered: {
                time.text = parseInt((time.text)*1+1);
                if (parseInt((time.text)*1) >= 100) {
                    time.text = "0";
                    chart.series(0).clear();
                }
                chart.series(0).append(parseInt(time.text), serialport.V_Dc * serialport.I_Dc);
                //time.lineCount++;
            }
        }
    }

    Dialog {
        id: chartDialog
        modal: true
        focus: true
        title: "Input Power Over Time"
        x: (window.width - width) / 2
        y: window.height / 6
        width: chart.width + 170
        contentHeight: chartColumn.height

        Column {
            id: chartColumn
            spacing: 20
            ChartView {
                id: chart
                //anchors.left: animation.right
                anchors.top:  animation1.top
                //anchors.leftMargin: 170
                anchors.topMargin: 450
                anchors.horizontalCenter: parent.horizontalCenter
                width: 500*window.width/1200
                height: 400*window.height/707
                axes: [
                    ValueAxis{
                        id: xAxis
                        min: 0.0
                        max: 100.0
                    },
                    ValueAxis{
                        id: yAxis
                        min: 0.0
                        max: 30.0
                    }
                ]
                Component.onCompleted: {
                    var series = chart.createSeries(ChartView.SeriesTypeLine, "Power", xAxis, yAxis);
                    series.append(serialport.V_Dc, serialport.I_Dc);
                }
            }
        }
    }
}
