import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

Item {
     property StackView stackView

    GridLayout {
        anchors.centerIn: parent
        columns: 2
        rowSpacing: 15
        columnSpacing: 20

        Label {
            text: "Port:"
            Layout.alignment: Qt.AlignRight
        }

        ComboBox {
            id: portBox
            Layout.preferredWidth: 150
            model: ["COM1","COM2","COM3","COM4","COM5","COM6","COM7","COM8","COM9","COM10"]
        }

        Label {
            text: "Baudrate:"
            Layout.alignment: Qt.AlignRight
        }

        ComboBox {
            id: baudBox
            Layout.preferredWidth: 150
            model: ["9600","19200","38400","57600","115200"]
            currentIndex: 4
        }

        Label {
            text: " "
            Layout.alignment: Qt.AlignRight
        }

        Button {
            text: "Open"
            Layout.preferredWidth: 80

            onClicked: {
                var ok = serialManager.openPort(
                            portBox.currentText,
                            parseInt(baudBox.currentText))

                if (ok) {
                    stackView.push(
                        Qt.resolvedUrl("ConfigScreen.qml"),
                        { stackView: stackView }
                    )
                }
                else {
                    errorDialog.open()
                    console.log("Connect failed")
                }
            }
        }

        MessageDialog {
            id: errorDialog
            title: "Error"
            text: "Connect failed"
        }
    }
}
