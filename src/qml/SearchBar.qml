import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.15

ToolBar {
    id: search_bar
    height: 60
    property var shouldSearch: false

    TextField {
        id: search_text
        width: 300
        padding: 15
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        placeholderText: qsTr("Search...")
        onTextChanged: {
            if(text.length == 0){
                main.pop();
                isSearching = false;
                shouldSearch = false;
                if(main.get(main.index).objectName == "HOME"){
                    allowReturn = false;
                }
            }
            else if(!isSearching){
                main.push("SearchResult.qml");
                isSearching = true;
                allowReturn = true;
                shouldSearch = true;
            }
            else{
                shouldSearch = true;
            }
        }
        onAccepted: doSearch(search_text.text)
        color: Material.primary
        placeholderTextColor: Material.primary
        cursorDelegate: Rectangle {
            visible: search_text.cursorVisible
            color: Material.primary
            width: search_text.cursorRectangle.width
        }
        background: Rectangle{
            radius: 15
            color: Material.background
        }
    }  

    ImageButton{
        id: explore_button
        anchors.right: setting_button.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        imageSource: "../assets/explore.png"
        //checkable: true
        onClicked: {
            //isLoggedIn = !isLoggedIn
        }
    }

    ImageButton{
        id: setting_button
        anchors.right: login_button.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        imageSource:  "../assets/settings.png"
        //checkable: true
        onClicked: {
            //isLoggedIn = !isLoggedIn
        }
    }

    ImageButton{
        id: login_button
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 20
        imageSource: isLoggedIn? "../assets/logout.png" : "../assets/login.png"
        //checkable: true
        onClicked: {
            if(isLoggedIn){
                main.clear();
                main.replace("Home.qml");
                backend.cr_logout();
                
            }
            else{
               // backend.startSession();
                backend.setStartup();
                main.clear();
                main.replace("Login.qml");
            }
        }
    }

    ImageButton{
        id: return_button
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        imageSource: "../assets/return.png"
        onClicked: {
            if(main.currentItem.objectName == "SEARCH"){
                isSearching = false;
                shouldSearch = true;
            }

            main.pop();

            if(main.currentItem.objectName == "HOME")
                allowReturn = false;
            alert.visible = false;
        }

        visible: allowReturn
    }

    SlidingMenu{
        id: sliding_menu
        anchors.top: parent.bottom
    }

    function doSearch(text){
        if(!isSearching){
            main.push("SearchResult.qml");
            isSearching = true;
            allowReturn = true;
        }

        if(shouldSearch){
            backend.search(text);
            shouldSearch = false;
        }
    }

    Connections {
        target: backend

        function onLogout(){
            isLoggedIn =  !isLoggedIn;
        }
    }
}