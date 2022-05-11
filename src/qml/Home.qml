import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15

ScrollView{
    objectName: "HOME"
    id: scrollview
    width: parent.width
    height: parent.height
    contentHeight:grid.height
    contentItem: content
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    clip: true

    ListModel {
            id: queue_model
            dynamicRoles: true
        }

        ListModel {
            id: simulcast_model
            dynamicRoles: true
        }

        ListModel {
            id: updated_model
            dynamicRoles: true
        }

        ListModel {
            id: history_model
            dynamicRoles: true
        }
    
        Component {
            id: delegate_history
            
    
            Column {
                id: wrapper
                padding: 10
                Episode{
                    id: episode
                    thumbnail: icon
                    episode_name: name
                    episode_number: number
                    completable: false
    
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            backend.fetchEpisodeList(collection_id)
                            backend.setPlaylistByID(media_id);
                            main.push("Player.qml");
                            allowReturn = true;
                        } 
                    }
                }
            }
        }

        Component {
            id: delegate
            Column {
                id: wrapper
                padding: 10
                Image {
                    id: image
                    source: icon
                    clip: true
                    width: 640
                    height: 320
                    
                    Rectangle{
                        id: backdrop
                        color: Material.background
                        width: parent.width
                        height: 75
                        opacity: 0.25
                    }

                    Text {
                        id: nameText
                        text: name
                        color: Material.primary
                        font.pointSize: 24
                        font.weight: Font.Black
                        style: Text.Outline
                        //styleColor: Material.primary
                        clip: true
                        anchors.fill: parent
                        anchors.margins: 10
                    }

                    MouseArea
                       {
                          anchors.fill: parent
                          onClicked: {
                              // get collection information here.
                              main.push("Series.qml", {"series_id": series_id, "name": name, "description": description, "portrait_icon": portrait_icon, "landscape_icon": icon})
                              allowReturn = true;
                          } 
                       }
                }
            }
        }
    
    Grid{
        id: grid
        columns: 1
        width: window.width
        Rectangle{
            id: queue
            width: parent.width
            height: 500
            color: Material.background
            border.width: 5

            Label {
                id: queue_label
                text: "Queue"
                color: Material.primary
                font.pointSize: 20
                //fontSizeMode: Text.Fit
                font.weight: Font.Bold
                style: Text.Raised
                anchors.horizontalCenter: parent.horizontalCenter
                padding: 15
            }

            ListView {
                id: queue_list
                anchors.fill: parent
                model: queue_model
                delegate: delegate
                orientation: ListView.Horizontal
                anchors.topMargin: 50
            }
        }

        Rectangle{
            id: simulcasts
            width: parent.width
            height: 500
            color: Material.background
            border.width: 5

            Label {
                id: simulcast_label
                text: "Simulcasts"
                color: Material.primary
                font.pointSize: 20
                //fontSizeMode: Text.Fit
                font.weight: Font.Bold
                style: Text.Raised
                anchors.horizontalCenter: parent.horizontalCenter
                padding:15
            }

            ListView {
                anchors.fill: parent
                model: simulcast_model
                delegate: delegate
                orientation: ListView.Horizontal
                anchors.top: simulcast_label.bottom
                anchors.topMargin: 50
            }
        }

        Rectangle{
            id: updated
            width: parent.width
            height: 500
            color: Material.background
            border.width: 5

            Label {
                id: updated_label
                text: "Updated"
                color: Material.primary
                font.pointSize: 20
                //fontSizeMode: Text.Fit
                font.weight: Font.Bold
                style: Text.Raised
                anchors.horizontalCenter: parent.horizontalCenter
                padding: 15
            }

            ListView {
                anchors.fill: parent
                model: updated_model
                delegate: delegate
                orientation: ListView.Horizontal
                anchors.top: updated_label.bottom
                anchors.topMargin: 50
            }
        }

        Rectangle{
            id: history
            width: parent.width
            height: 500
            color: Material.background
            border.width: 5

            Label {
                id: history_label
                text: "History"
                color: Material.primary
                font.pointSize: 20
                //fontSizeMode: Text.Fit
                font.weight: Font.Bold
                style: Text.Raised
                anchors.horizontalCenter: parent.horizontalCenter
                padding: 15
            }

            ListView {
                anchors.fill: parent
                model: history_model
                delegate: delegate_history
                orientation: ListView.Horizontal
                anchors.top: history_label.bottom
                anchors.topMargin: 50
            }
        }
        

    }

    Connections {
        target: backend

        function onAddSimulcast(data, img) {
            data = JSON.parse(data);
            if(simulcast_model.count <= 20){
                //console.log(JsonObject.name);
                 simulcast_model.append({"name": data.name, "icon": img, "series_id": data.id, "description": data.description, "portrait_icon": data.portrait_icon});
             }
        }  

        function onAddUpdated(data, img) {

            data = JSON.parse(data);
            if(simulcast_model.count <= 20){
                //console.log(JsonObject.name);
                 updated_model.append({"name": data.name, "icon": img, "series_id": data.id, "description": data.description, "portrait_icon": data.portrait_icon});
             }
       } 

        function onAddWatchHistory(data){
            data = JSON.parse(data);
            var count = Object.keys(data).length;
            for(let i = 0; i < count; i++){
                var name = data[i].name;
                var ep_num = data[i].episode_number;
                var icon = data[i].thumbnail;
                var media_id = data[i].media_id;
                var collection_id = data[i].collection_id

                //backend.addMediaToPlaylist(media_id, name, ep_num, collection_id, icon)
                history_model.append({"name": name, "icon": icon, "number": ep_num, "media_id": media_id, "collection_id": collection_id});
            }
        }

        function onAddWatchHistoryDynamic(data){
            data = JSON.parse(data);
            var count = Object.keys(data).length;
            for(let i = 0; i < count; i++){
                var name = data[i].name;
                var ep_num = data[i].episode_number;
                var icon = data[i].thumbnail;
                var media_id = data[i].media_id;
                var collection_id = data[i].collection_id

                //backend.addMediaToPlaylist(media_id, name, ep_num, collection_id, icon)
                history_model.insert(0, {"name": name, "icon": icon, "number": ep_num, "media_id": media_id, "collection_id": collection_id});
            }
        }

        function onAddQueue(data){
            data = JSON.parse(data);
            queue_model.append({"name": data.name, "icon": data.landscape, "series_id": data.series_id, "description": data.description, "portrait_icon": data.portrait});
        }

        function onRemoveQueue(data){
            var count = queue_model.count;

            for(var i = 0; i < count; i++){
                var series_id = queue_model.series_id;
                if(series_id = data){
                    queue_model.clear();
                    backend.getQueue();
                    break;
                }
            }

        }
    }


    Component.onCompleted: {
        backend.getSimulcast();
        backend.getWatchHistory();
        backend.getQueue();
        backend.getUpdated();
        // always visible
        window.header.visible = true;
        alert.visible = false
    }
}

