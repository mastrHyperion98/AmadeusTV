import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15

ScrollView{
    id: scrollview
    property var series_id: 0
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    clip: true

    Rectangle{
        anchors.fill: parent

        color: "red"

        Button{
            text:series_id
            onClicked: {
                main.pop()
            }
        }
    }

    Connections {
        target: backend

    
    }


    Component.onCompleted: {
    }
}