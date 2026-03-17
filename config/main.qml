import QtQuick 2.12
import QtQuick.Controls 2.12

ApplicationWindow {
    id: root
    width: 1000
    height:500
    visible: true
    title: "DTL Configuration"

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: HomeScreen {
            stackView: stack
        }
    }


    // Status góc phải
    Text {
        text: serialManager.connected ? "Connected" : "Disconnected"
        color: serialManager.connected ? "green" : "red"
        font.pixelSize: 10
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 9
        anchors.rightMargin: 25
        font.bold: true
    }
}
