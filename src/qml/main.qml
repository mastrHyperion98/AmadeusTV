import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs 1.1

ApplicationWindow{
    id: window
    minimumHeight: 720
    minimumWidth: 1280
    width: 1280
    height: 720
    title: "AmadeusTV"
    visible: true
    visibility: is_deck ? Window.FullScreen : Window.Windowed
    property var isSearching: false
    property var allowReturn: false
    property bool isLoggedIn: false
    property var isRememberMe: false
    property var firstStart: true
    property bool is_deck: false

    Material.theme: Material.Dark
    Material.accent: "#DD2C00"
    Material.background: "#212121"
    Material.primary: "#FF6D00"

    header: SearchBar {
        id: header
        height: 60
    }

    StackView{
        id: main
        anchors.fill: parent
    
    }
    
    Component.onCompleted: {
        backend.setStartup();
        alert.visible = false;
    }


    Connections {
        target: backend

        function onStartup(settings) {
            var data = JSON.parse(settings);
            
            isLoggedIn = data.login;
            isRememberMe = data.is_remember_me;
            firstStart = data.first_time;

            if(isLoggedIn){
                main.push("Home.qml");
            }
            else{
                main.push("Login.qml");
            }

        }  
        function onAlert(msg){
            alert.message = msg
            alert.visible = true
            alert.startAnim();
        }
    }

    Rectangle{
        id: alert
        x: (parent.width / 2) - (width/2)
        y: 25
        height: 50
        width: 750
        color: "#b71c1c"
        property alias message: alert_msg.text

        SequentialAnimation {
            id: anim
            NumberAnimation { target: alert; property: "x"; to: alert.x - 25; duration: 10}
            NumberAnimation { target: alert; property: "x"; to: alert.x + 25; duration: 10}
            NumberAnimation { target: alert; property: "x"; to: alert.x; duration: 10}
        }

        ImageButton{
            id: exit_button
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            imageSource: "../assets/close_button_white.png"
            onClicked: {
               alert.visible = false
            }
        }

        Text {
            id: alert_msg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.right: exit_button.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            font.pointSize: 12
            color: "#ff8a80"
            wrapMode: Text.WordWrap
        }
        visible: true

        function startAnim(){
            anim.restart();
        }
    }
}
