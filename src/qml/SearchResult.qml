import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15


Rectangle{
    objectName: "SEARCH"
    color: Material.background
    property int numCol: parent.width / 400;
    property double heightMultiplier: 240 / parent.height

    GridView{
        id: search_results
        model: search_model
        delegate: delegate
        width: parent.width
        height: parent.height
        snapMode: GridView.SnapToRow
        cellWidth: parent.width / numCol
        cellHeight: parent.height * heightMultiplier
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter

    }
    ListModel {
        id: search_model
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
                width: search_results.cellWidth - 10
                height: search_results.cellHeight - 60

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
                    //fontSizeMode: Text.Fit
                    font.weight: Font.Black
                    style: Text.Outline
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

    Connections {
        target: backend

       function onSearching(){
           search_model.clear();
       }

       function onAddSearch(data, img) {
            data = JSON.parse(data);
            if(search_model.count <= 100){
                //console.log(JsonObject.name);
                search_model.append({"name": data.name, "icon": img, "series_id": data.id, "description": data.description, "portrait_icon": data.portrait_icon});
            }
        } 
    }
}