import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.4

Rectangle{
    id: menu
    height: window.height
    width: 300
    color: Material.background
    x: parent.width + 10
    y: 0
    state: "HIDDEN"

    Button {
        id: explore
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: logout.top
        anchors.margins: 15
        text: "Explore"
        width: 200
        font.pointSize: 18
        font.capitalization: Font.MixedCase
        onClicked: {
            main.push("Explore.qml");
            window.allowReturn = true;
            sliding_menu.state = "HIDDEN";
        }
    }

    Button {
        id: logout
        anchors.horizontalCenter: parent.horizontalCenter
         anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 15
        text: "Logout"
        width: 200
        font.pointSize: 18
        font.capitalization: Font.MixedCase
        
        onClicked: {
            backend.cr_logout();
            sliding_menu.state = "HIDDEN";
            main.replace("Login.qml");
        }
    }

    Button {
        id: exit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logout.bottom
        anchors.margins: 15
        text: "Exit"
        width: 200
        font.pointSize: 18
        font.capitalization: Font.MixedCase
        
        onClicked: {
            window.close('','_parent','');
        }
    }

    states: [
        State {
            name: "HIDDEN"
            PropertyChanges {
                target: menu
                x: parent.width + 10
            }
        },
        State {
            name: "VISIBLE"
            PropertyChanges {
                target: menu
                x: parent.width - width
            }
        }
    ]
    transitions: Transition {
         NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad }
    }

    DropShadow {
        anchors.fill: menu
        cached: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 17
        spread: 0.60
        color: Material.accent
        source: menu
    }

    Connections {
        target: backend
    }
}