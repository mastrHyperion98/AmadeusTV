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
    color: Material.background
    clip: true

    ListModel {
        id: episode_model
        dynamicRoles: true
    }

    Component {
        id: delegate
        

        Column {
            id: wrapper
            padding: 10
            property alias state: episode.state
            Episode{
                id: episode
                thumbnail: icon
                episode_name: name
                episode_number: number
                state: is_watched? "WATCHED":"TOWATCH"

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        backend.setPlaylistIndex(index);
                        main.push("Player.qml");
                        allowReturn = true;
                    } 
                }
            }
        }
    }

    ListModel {
        id: collection_model
        dynamicRoles: true
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
            color: Material.primary
            font.pointSize: 24
            font.weight: Font.Black
            style: Text.Outline
            anchors.top: parent.top 
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 15
        }


        Rectangle{
            id: series_header_content
            anchors.top: series_name.bottom
            anchors.topMargin: 25
            width: 600
            height: 325
            color: Material.background

            Image{
                id: portrait
                source: portrait_icon
                anchors.left: parent.left
                anchors.margins: 25
                anchors.verticalCenter: parent.verticalCenter
                width: 225
                height: 325
            }
        
            ScrollView {
                id: view
                anchors.left: portrait.right
                width: parent.width - portrait.width - 50
                height: 325
                anchors.leftMargin: 25
                contentHeight:series_description.height
                contentItem: series_description
                clip: true
    
                //ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    
                Text{
                    id: series_description
                    text: description
                    width: view.width
                    //height: 200
                    wrapMode: Text.WordWrap
                    color: Material.primary
                    font.pointSize: 16
                }
            }

        }
    
        Rectangle{
            id: collections
            width: 575
            height: 75
            anchors.top: series_header_content.bottom
            anchors.left: series_header_content.left
            anchors.topMargin: 25
            anchors.leftMargin: 25
            
            color: Material.background

            ComboBox {
                id: collection_box
                width: parent.width
                height: 50
                currentIndex: 0
                model: collection_model
                textRole: "name"
                clip: true

                background: Rectangle {
                    color: Material.primary
                }

                delegate: ItemDelegate {
                    id:itemDlgt
                    width: collection_box.width
                    height:80

                    contentItem: Text {
                        id:textItem_speed
                        text: name
                        color: hovered?Material.accent:"white"
                        wrapMode: Text.WordWrap
                        font.pointSize: 12
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                    }
                }
                
                contentItem: Text {
                    leftPadding: 10
                    text: collection_box.displayText
                    color: "white"
                    font.pointSize: 12
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }

                popup: Popup{
                    y: collection_box.height - 1
                    width: collection_box.width
                    height:contentItem.implicitHeigh
                    padding: 1

                    contentItem: ListView {
                        id:listView_speed
                        implicitHeight: contentHeight
                        model: collection_box.popup.visible ? collection_box.delegateModel : null
                
                        ScrollIndicator.vertical: ScrollIndicator { }
                        
                    }
                    
                    background: Rectangle{
                        color: Material.primary
                    }

                }

                onActivated: {
                    var id = collection_model.get(currentIndex).collection_id;
                    episode_model.clear();
                    backend.fetchEpisodeList(id);
                }
            }
        }
        

        Rectangle{
            id: episodes_content
            width: 600
            height: parent.height - series_name.height
            anchors.right: parent.right
            anchors.top: series_name.bottom
            anchors.margins: 25
            color: Material.background

            ListView {
                id: episode_views
                anchors.fill: parent
                model: episode_model
                delegate: delegate
                orientation: ListView.Vertical
                clip: true
            }        
        }
    }

    Connections {
        target: backend

        function onGetEpisodes(data) {
            data = JSON.parse(data);
            var count = Object.keys(data).length;
           
            for(let i = 0; i < count; i++){
                var name = data[i].name;
                var ep_num = data[i].episode_number;
                var icon = data[i].thumbnail;
                var media_id = data[i].media_id;
                var collection_id = data[i].collection_id
                var isWatched = data[i].isWatched

                backend.addMediaToPlaylist(media_id, name, ep_num, collection_id)
                episode_model.append({"name": name, "icon": icon, "number": ep_num, "media_id": media_id, "collection_id": collection_id, "is_watched": isWatched});
            }
        }
        function onGetCollections(data) {
            data = JSON.parse(data);
            var count = Object.keys(data).length;
           
            for(let i = 0; i < count; i++){
                var name = data[i].name;
                var series_id = data[i].series_id;
                var colletion_id = data[i].collection_id

                collection_model.append({"name": name, "series_id": series_id, "collection_id": colletion_id});
            }
        } 
        function onSetWatched(id) {
            for(let i=0; i < episode_model.count; i++){
                var ep = episode_model.get(i);
                if(id == ep.media_id){
                    var episode_i = episode_views.itemAtIndex(i);
                    episode_i.state = "WATCHED";
                }
            }
        }
    }

    Component.onCompleted: {
        backend.fetchCollections(series_id)
        alert.visible = false
    }
}