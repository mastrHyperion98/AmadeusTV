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
    contentHeight: content.height
    contentItem: content
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    clip: true

    Rectangle{
        id: content
        width: parent.width
        height: 1440
        color: Material.background
        

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

        Component {
            id: delegate
            Column {
                id: wrapper
                padding: 10
                Image {
                    id: image
                    source: icon
                    clip: true

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


        Rectangle{
            id: queue
            width: parent.width
            height: 500
            color: Material.background
            border.width: 5
            

            Label {
                id: queue_label
                text: "Watch List"
                color: Material.primary
                font.pointSize: 20
                //fontSizeMode: Text.Fit
                font.weight: Font.Bold
                style: Text.Raised
                anchors.horizontalCenter: parent.horizontalCenter
                padding: 15
            }

            ListView {
                id: queueview
                anchors.fill: parent
                anchors.top: queue_label.bottom
                anchors.topMargin: 50
                model: queue_model
                delegate: delegate
                orientation: ListView.Horizontal
                clip: true
            }
        }

        Rectangle{
            id: simulcasts
            width: parent.width
            height: 500
            color: Material.background
            anchors.top: queue.bottom
            anchors.topMargin: -30
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
            anchors.top: simulcasts.bottom
            anchors.topMargin: -30
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

    }

    Connections {
        target: backend

        function onAddSimulcast(data, img) {
            data = JSON.parse(data);
            if(simulcast_model.count <= 10){
                //console.log(JsonObject.name);
                 simulcast_model.append({"name": data.name, "icon": img, "series_id": data.id, "description": data.description, "portrait_icon": data.portrait_icon});
             }
        }  

        function onAddUpdated(data, img) {

            data = JSON.parse(data);
            if(simulcast_model.count <= 10){
                //console.log(JsonObject.name);
                 updated_model.append({"name": data.name, "icon": img, "series_id": data.id, "description": data.description, "portrait_icon": data.portrait_icon});
             }
       } 

       function onAddQueue(id, img) {
           
            if(queue_model.count <= 10){
                var split = id.split("__UUID__");
                var name = split[0]
                var id = split[1]
                queue_model.append({"name": name, "icon": img, "series_id": id});
            }
        } 
    }


    Component.onCompleted: {
        backend.getSimulcast();
        backend.getUpdated();
        // always visible
        window.header.visible = true;
        alert.visible = false
    }
}

