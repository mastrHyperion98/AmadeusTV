import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15

Rectangle{
    id: root
    property var series_id: 0
    property string name: "Placeholder"
    property string description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    property var portrait_icon: ""
    property var landscape_icon: "" 
    color: Material.accent
    clip: true

    ListModel {
        id: collection_model
        dynamicRoles: true
    }

    Component {
        id: delegate
        Column {
            id: wrapper
            padding: 10
            anchors.horizontalCenter: parent.horizontalCenter
            Episode{
                thumbnail: icon
                episode_name: name
                episode_number: number
            }
        }
    }

    Rectangle{
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        width: 1280
        color: Material.background

        Text {
            id: series_name
            text: name
            color: Material.accent
            font.pointSize: 24
            font.weight: Font.Black
            style: Text.Outline
            styleColor: Material.primary
            anchors.top: parent.top 
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 15
        }

        Rectangle {
            id: series_header_content
            anchors.top: series_name.bottom
            width: parent.width
            height: 400
            color: Material.background

            Image{
                id: portrait
                source: portrait_icon
                anchors.left: parent.left
                anchors.margins: 30
                anchors.verticalCenter: parent.verticalCenter
                width: 200
                height: 325
            }

            Text{
                id: series_description
                wrapMode: Text.WordWrap
                text: description
                color: Material.accent
                font.pointSize: 16
                anchors.left: portrait.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 50
            }
        }
        

        Rectangle{
            id: episodes_content
            width: parent.width
            height: parent.height - series_header_content.height - series_name.height
            anchors.right: parent.right
            anchors.left: parent.left 
            anchors.top: series_header_content.bottom
            color: Material.background

            ListView {
                anchors.fill: parent
                model: collection_model
                delegate: delegate
                orientation: ListView.Vertical
                clip: true
            }        
        }
    }

    Connections {
        target: backend

        function onFetchEpisodes(data) {
            data = JSON.parse(data);
            var count = Object.keys(data).length;
           
            for(let i = 0; i < count; i++){
                var name = data[i].name;
                var ep_num = data[i].episode_number;
                var icon = data[i].thumbnail;
                var media_id = data[i].media_id;

                collection_model.append({"name": name, "icon": icon, "number": ep_num, "media_id": media_id});
            }
        }  
    
    }


    Component.onCompleted: {
        backend.fetchCollections(series_id)
    }
}