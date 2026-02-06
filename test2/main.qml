import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import App.Models 1.0

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Task Manager")

    TaskModel {
            id: taskModel
        }

    ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ===== Input area =====
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: taskInput
                    Layout.fillWidth: true
                    placeholderText: "Enter a task..."
                }

                Button {
                    text: "Add"
                    onClicked: {                        
                        taskModel.addTask(taskInput.text)
                        taskInput.text = ""
                    }
                }
            }

            // ===== List of tasks (empty) =====
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                model: taskModel

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 40
                    color: "#90EE90"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        CheckBox {
                            checked: done
                            onToggled: {
                                    taskModel.setDone(index, checked)
                            }
                        }

                        Text {
                            text: name
                            verticalAlignment: Text.AlignVCenter

                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                        }

                        Button {
                              text: "❌"
                              onClicked: taskModel.deleteTask(index)
                        }
                    }
                }

            }

            // ===== Footer =====
            Label {
                text: "Done: " + taskModel.doneCount + " / " + taskModel.totalCount
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }
}
