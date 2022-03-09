import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15

ApplicationWindow{
    id: window
    minimumHeight: 720
    minimumWidth: 1280
    width: 1280
    height: 720
    visible: true
    property var isSearching: false
    property var allowReturn: false

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
        main.push("Home.qml")
    }
}
