import QtQuick 2.12
import QtQuick.Window 2.12
import Qt.labs.platform 1.0
import QtQuick.Controls 2.12

Window {
    id: root
    width: 640
    height: 480
    minimumWidth: 640
    minimumHeight: 480
    visible: true
    title: qsTr("Copy File")
    color: '#DEFFDC'

    property bool flag: true

    DragAndDrop {
        id: droparea

        property string file: ''

        visible: root.flag
        anchors.fill: parent
        anchors.margins: 20
        onDropped: {
            file = drop.urls[0];
            dialog.open();
        }
    }

    FolderDialog {
        id: dialog
        title: 'Выберите папку для сохранения'
        onAccepted: {
            root.flag = false;
            if (pyLoader.tobytes(droparea.file, folder)) timer.start();
        }
    }

    Rectangle {
        visible: !root.flag
        anchors.fill: parent
        anchors.margins: 30
        color: 'transparent'

        Text {
            font.pointSize: 14
            anchors.left: parent.left
            anchors.top: parent.top
            text: 'Файл для копирования:\n\n' + droparea.file.substring(8)
        }

        ProgressBar {
            id: progress
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 80
            from: 0
            to: 100
            opacity: value === 100 ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        Timer {
            id: timer
            repeat: true
            interval: 500
            onTriggered: {
                progress.value += 10;
                _model.append({_value: pyLoader.getbytes(progress.value / 10 - 1) })
                view.positionViewAtEnd();
                if (progress.value === 100) timer.stop();
            }
        }

        ListView {
            id: view
            anchors.top: progress.bottom
            anchors.bottom: ok.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            clip: true
            model: _model

            delegate: Text {
                width: view.width
                wrapMode: Text.WrapAnywhere
                font.pointSize: 14
                text: _value
            }

            ListModel {
                id: _model
            }
        }

        Button {
            id: ok
            height: 40
            width: 120
            text: timer.running ? 'Cancel' : 'OK'
            background: Rectangle { border.width: 1; color: ok.down ? 'grey' : 'white'; radius: 5; }
            font.pointSize: 14
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onReleased: {
                root.flag = true;
                timer.stop();
                progress.value = 0;
                _model.clear();
            }
        }
    }
}
