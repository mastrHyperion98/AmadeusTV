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
    property int numCol: parent.width / 320;
    property double heightMultiplier: 160 / parent.height

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
                    color: Material.accent
                    font.pointSize: 24
                    //fontSizeMode: Text.Fit
                    font.weight: Font.Black
                    style: Text.Outline
                    styleColor: Material.primary
                    clip: true
                    anchors.fill: parent
                    anchors.margins: 10
                }

                MouseArea
                   {
                      anchors.fill: parent
                      onClicked: {
                          // get collection information here.
                          main.push("Series.qml", {"series_id": series_id})
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

       function onAddSearch(id, img) {
            if(search_model.count <= 100){
                var split = id.split("__UUID__");
                var name = split[0]
                var id = split[1]
                search_model.append({"name": name, "icon": img, "series_id": id});
            }
        } 
    }
/*
    Connections {
        target: 
        function onTextChanged() {
            if(text.length == 0){
                search_model.clear();
            }
            else if(text.length %3 == 0){
                //search_model.clear();
                //doSearch(search_text.text);
            }
        }
    }*/
}