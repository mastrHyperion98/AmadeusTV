import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.15

ToolBar {
    height: 60

    TextField {
        id: search_text
        width: 300
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        property bool ignoreTextChange: false
        placeholderText: qsTr("Search...")
        onTextChanged: {
            if (!ignoreTextChange)
            //searchTextChanged(text)
            var a = 10;
        }
        onAccepted: doSearch(searchText.text)
        color: Material.primary
        placeholderTextColor: Material.primary
        horizontalAlignment: TextInput.AlignHCenter

        background: Rectangle{
            radius: 15
            color: Material.accent
        }
    }   

    ImageButton{
        id: menu_button
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        imageSource: "../../assets/menu.png"
    }
}