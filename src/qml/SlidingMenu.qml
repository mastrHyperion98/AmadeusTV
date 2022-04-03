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
        anchors.bottom: settings.top
        anchors.margins: 15
        text: "Explore"
        width: 200
        font.pointSize: 18
        font.capitalization: Font.MixedCase
        //onClicked: model.submit()
    }

    Button {
        id: settings
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 15
        text: "Settings"
        width: 200
        font.pointSize: 18
        font.capitalization: Font.MixedCase
        //onClicked: model.submit()
    }

    Button {
        id: login
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: settings.bottom
        anchors.margins: 15
        text: "Logout"
        width: 200
        font.pointSize: 18
        font.capitalization: Font.MixedCase
        
        onClicked: {
            if(isLoggedIn){
                text = "Login";
                //backend.cr_logout();
                //sliding_menu.state = "HIDDEN";
                

            }
            else{
                text = "Logout";
                //backend.startSession();
                //main.replace("Login.qml");
                //sliding_menu.state = "HIDDEN";
            }

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

        function onLogout(){
            window.update();
            isLoggedIn =  false;
            sliding_menu.state = "HIDDEN";
        }
    }
}