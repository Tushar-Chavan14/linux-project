// tushar-os SDDM greeter: blurred wallpaper, big clock, glass login card.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import SddmComponents 2.0 as Sddm

Rectangle {
    id: root
    width: 1920; height: 1080
    color: "#11111b"

    readonly property color base: "#1e1e2e"
    readonly property color text: "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    readonly property color accent: config.accent || "#cba6f7"
    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property int sessionIndex: sessionModel.lastIndex

    Image {
        id: wall
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        visible: false
    }
    MultiEffect {
        anchors.fill: wall
        source: wall
        blurEnabled: true
        blur: 0.6
        brightness: -0.15
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.14
        spacing: 4
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Orbitron"; font.pixelSize: 110
            color: "#f5c2e7"
            text: Qt.formatTime(new Date(), "hh:mm")
        }
        Text {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Inter"; font.pixelSize: 20
            color: root.text
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
        }
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: { clock.text = Qt.formatTime(new Date(), "hh:mm"); date.text = Qt.formatDate(new Date(), "dddd, MMMM d") }
        }
    }

    Rectangle {
        id: card
        width: 380; height: 300
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 120
        radius: 20
        color: Qt.rgba(0.118, 0.118, 0.18, 0.62)
        border.color: Qt.rgba(0.8, 0.84, 0.96, 0.10)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 14

            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "file:///usr/share/icons/hicolor/scalable/apps/tushar-os-logo.svg"
                sourceSize.width: 56; sourceSize.height: 56
            }
            ComboBox {
                id: user
                Layout.fillWidth: true
                model: userModel
                textRole: "name"
                currentIndex: root.userIndex
                font.family: "Inter"; font.pixelSize: 15
            }
            TextField {
                id: password
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                font.family: "Inter"; font.pixelSize: 15
                color: root.text
                focus: true
                background: Rectangle { radius: 12; color: Qt.rgba(0.19, 0.2, 0.27, 0.8); border.color: password.activeFocus ? root.accent : "transparent" }
                Keys.onReturnPressed: login()
            }
            Button {
                Layout.fillWidth: true
                text: "Log in"
                font.family: "Inter"; font.pixelSize: 15
                onClicked: login()
                background: Rectangle { radius: 12; color: root.accent }
                contentItem: Text { text: parent.text; font: parent.font; color: root.base; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Text {
                id: error
                Layout.alignment: Qt.AlignHCenter
                color: "#f38ba8"; font.family: "Inter"; font.pixelSize: 13
                text: ""
            }
        }
    }

    Row {
        anchors.right: parent.right; anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 18
        Repeater {
            model: [ { label: "⏾", act: function() { sddm.suspend() } },
                     { label: "", act: function() { sddm.reboot() } },
                     { label: "⏻", act: function() { sddm.powerOff() } } ]
            delegate: Text {
                text: modelData.label; color: root.subtext
                font.family: "Symbols Nerd Font"; font.pixelSize: 24
                MouseArea { anchors.fill: parent; onClicked: modelData.act() }
            }
        }
    }

    function login() { sddm.login(user.currentText, password.text, root.sessionIndex) }
    Connections {
        target: sddm
        function onLoginFailed() { error.text = "Wrong password"; password.text = "" }
    }
}
