import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs 1.1
Rectangle{
    id: content
    anchors.horizontalCenter: parent.horizontalCenter
    height: parent.height
    width: 1280
    color: Material.background

    Image{
        id: crunchy_logo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 25
        anchors.bottom: email_field.top
        source: "../assets/crunchyroll-logo.png"
        width: 768
        height: 144
    }


    TextField {
        id: email_field
        width: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        placeholderText: qsTr("email")
    }   

    TextField {
        id: password_field
        width: 500
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: email_field.bottom
        anchors.margins: 25
        echoMode: TextInput.Password

        placeholderText: qsTr("password")
    }
    
    CheckBox {
        id: remember_me
        anchors.top: password_field.bottom
        anchors.left: password_field.left
        //anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 25
        checked: isRememberMe
        text: qsTr("Remember Me")

        onToggled: backend.setRememberMe(checked);
    }

    Text {
        id: forgot_password
        //anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: password_field.bottom
        anchors.right: password_field.right
        anchors.verticalCenter: remember_me.verticalCenter
        anchors.topMargin: 40
        textFormat: Text.StyledText
        font.pointSize: 12
        linkColor: Material.primary
        text: "<a href=\"https://www.crunchyroll.com/resetpw\">Forgot Password ?</a>."
        onLinkActivated: Qt.openUrlExternally(link)
    }

    Button{
        id: login
        anchors.top: remember_me.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 25
        width: 475 - remember_me.width
        text: "Login"

        onClicked: {
            var email = email_field.text;
            var password = password_field.text;
            if(email != "" & password != "")
                backend.setLogin(email, password);
        }
    }

    Component.onCompleted: {
        window.header.visible = !firstStart;
        alert.visible = false
    }


    Connections {
        target: backend

        function onLogin(success){
            if(success){
                main.replace("Home.qml");
                alert.message = "";
                alert.visible = false;
            }
        }

    }
}