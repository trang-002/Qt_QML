import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import QtQuick.Dialogs 1.3

Item {
    id: root

    property StackView stackView
    property int currentModule: 0
    property bool appliedSinceSave: false
    property bool hasError: false
    property bool applyHasError: false

    function recomputeError() {

        root.hasError = false

        for(let i=0;i<paramModel.count;i++){
            if(paramModel.get(i).error){
                root.hasError = true
                return
            }
        }
    }

    Row {

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 32
        spacing: 10

        Button {

            text: "Load Parameter"
            font.pixelSize: 11
            background: Rectangle {
                radius: 4
                color: "#dcdcdc"
                border.color: "#b0b0b0"
                border.width: 1
            }
            padding: 6
            onClicked: {

                        console.log("Load parameter")
                        paramModel.clear()
                        serialManager.loadParameters()
           }
        }
    }

    ListModel {
        id: paramModel
    }
    Connections {
        target: serialManager

        onParamReceived: {
            console.log("PARAM:", name, value)

            paramModel.append({
                sys: sys,
                comp: comp,
                msg: msg,
                name: name,
                value: value,
                original: value,
                error: false
            })
        }
    }

    Connections {

        target: serialManager

        onParamApplied: {
                console.log("APPLIED", sys, comp, msg)

                for(let i=0;i<paramModel.count;i++){
                    let p = paramModel.get(i)

                    if(p.sys===sys && p.comp===comp && p.msg===msg){
                        paramModel.setProperty(i,"error",false)
                        paramModel.setProperty(i,"original",p.value)
                    }
                }
                root.recomputeError()
        }

        onParamError: {
            console.log("ERROR:", reason)
            root.applyHasError = true
            for(let i=0;i<paramModel.count;i++){
                let p = paramModel.get(i)

                if(p.sys===sys && p.comp===comp && p.msg===msg){
                    paramModel.setProperty(i,"error",true)
                }
            }
            root.recomputeError()
        }

        onApplyFinished: {

            if(root.applyHasError){

                messageDialog.title = "Apply Failed"
                messageDialog.text = "Some parameters are invalid."
                messageDialog.open()

            } else {

                messageDialog.title = "Apply Success"
                messageDialog.text = "All parameters applied successfully."
                messageDialog.open()
            }
        }


    }

    Component.onCompleted: {
        console.log("serialManager =", serialManager)
    }


    function hasChanges() {

            for (let i = 0; i < paramModel.count; i++) {
                let p = paramModel.get(i)

                if (p.value !== p.original)
                    return true
            }

            return false
        }

    // ================= MAIN UI =================

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // -------- Top bar --------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "Data Management"
                background: Rectangle {
                    radius: 4
                    color: "#f5f5f5"
                    border.width: root.currentModule === 0 ? 4 : 0
                    border.color: "#d0d0d0"
                }
                onClicked: root.currentModule = 0
            }

            Button {
                text: "Communicaton Management"
                background: Rectangle {
                    radius: 4
                    color: "#f5f5f5"
                    border.width: root.currentModule === 1 ? 4 : 0
                    border.color: "#d0d0d0"
                }
                onClicked: root.currentModule = 1
            }

            Button {
                text: "Encoder/Decoder"
                background: Rectangle {
                    radius: 4
                    color: "#f5f5f5"
                    border.width: root.currentModule === 2 ? 4 : 0
                    border.color: "#d0d0d0"
                }
                onClicked: root.currentModule = 2
            }

            Button {
                text: "Periperal Controller"
                background: Rectangle {
                    radius: 4
                    color: "#f5f5f5"
                    border.width: root.currentModule === 3 ? 4 : 0
                    border.color: "#d0d0d0"
                }
                onClicked: root.currentModule = 3
            }

            Button {
                text: "Transceiver AD9361"
                background: Rectangle {
                    radius: 4
                    color: "#f5f5f5"
                    border.width: root.currentModule === 4 ? 4 : 0
                    border.color: "#d0d0d0"
                }
                onClicked: root.currentModule = 4
            }

            Item { Layout.fillWidth: true }
        }

        // -------- Parameter list --------
        Rectangle {

            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#fafafa"
            border.color: "#d0d0d0"
            border.width: 2
            radius: 4

            anchors.margins: 10

            Flickable {

                    id: flick
                    anchors.fill: parent
                    anchors.margins: 30

                    contentWidth: parent.width
                    contentHeight: column.height

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }

                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.DragOverBounds
                    clip: true

                    Column {

                        id: column
                        width: flick.width
                        spacing: 12

                        Repeater {

                            model: paramModel

                            delegate: Item {

                                width: column.width
                                height: model.comp === root.currentModule ? 40 : 0
                                visible: model.comp === root.currentModule

                                GridLayout {

                                    anchors.left: parent.left
                                    anchors.leftMargin: 40

                                    columns: 2
                                    columnSpacing: 40

                                    Label {
                                        text: name
                                        Layout.preferredWidth: 200
                                    }

                                    TextField {

                                        id: field
                                        Layout.preferredWidth: 100
                                        text: value
                                        horizontalAlignment: Text.AlignRight

                                        background: Rectangle {
                                            border.width: 1
                                            border.color: {
                                                           if (error)
                                                           return "red"
                                                           if (field.text !== model.original)
                                                                return "orange"
                                                           return "#666"
                                                        }
                                        }

                                        onTextChanged: {
                                            paramModel.setProperty(index,"value",text)
                                            paramModel.setProperty(index,"error",false)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }



        // -------- Bottom buttons --------
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                    text: "Reset"
                    onClicked: {
                       for (let i = 0; i < paramModel.count; i++) {
                                    paramModel.setProperty(
                                        i,
                                        "value",
                                        paramModel.get(i).original
                                    )}
                       appliedSinceSave = false
                       }
                    }

            Button {
                    text: "Apply"
                    enabled: root.hasChanges()
                    onClicked: {
                            root.applyHasError = false
                            var list = []
                            for (let i = 0; i < paramModel.count; i++) {
                                let p = paramModel.get(i)
                                if (p.value !== p.original) {
                                    list.push({
                                        sys: p.sys,
                                        comp: p.comp,
                                        msg: p.msg,
                                        value: p.value
                                    })
                                }
                            }
                            serialManager.applyParams(list)
                            appliedSinceSave = true
                        }
                   }

            Button {
                    text: "Save"
                    enabled: appliedSinceSave && !root.hasError
                    onClicked: {
                                serialManager.saveFlash()
                                console.log("Saving to device")
                                appliedSinceSave = false
                                saveSuccessDialog.open()
                               }
                    }

             Button {
                    text: "Back"
                    onClicked: {
                                serialManager.closePort()
                                stackView.pop()
                               }
                    }
        }
    }

    MessageDialog {
        id: messageDialog
        title: ""
        text: ""
    }

    MessageDialog {
        id: saveSuccessDialog

        title: "Notification"
        text: "Save successful!"
        icon: StandardIcon.Information
    }
}

