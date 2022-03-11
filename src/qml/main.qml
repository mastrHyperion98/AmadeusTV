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
    property var isSearching: false
    property var allowReturn: false
    property bool isLoggedIn: false
    property var isRememberMe: false
    property var firstStart: true

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
        alert.visible = false
        //main.push("Home.qml");
    }


    Connections {
        target: backend

        function onStartup(settings) {
            var data = JSON.parse(settings);
            
            isLoggedIn = data.login;
            isRememberMe = data.is_remember_me;
            firstStart = data.first_time;

            if(isLoggedIn){
                console.log(isLoggedIn);
                main.push("Home.qml");
            }
            else{
                main.push("Login.qml");
            }

        }  

        function onAlert(msg){
            alert.message = msg
            alert.visible = true
        }
    }

    Rectangle{
        id: alert
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: 25
        height: 50
        width: 750
        color: "#b71c1c"
        property alias message: alert_msg.text

        Text {
            id: alert_msg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "HELLO ALERT WORLD"
            font.pointSize: 12
            color: "#ff8a80"
        }
        visible:false
    }
}
