import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.4


Rectangle{
    id: root
    property var thumbnail: ""
    property var episode_id: ""
    property var episode_name: ""
    property var episode_number: 0


    width: 750
    height: 300
    color: Material.background

    states: [
        State {
            name: "WATCHED"
            PropertyChanges { target: completion_item; visible: true;}
        },
        State{
            name: "TOWATCH"
            PropertyChanges {target: completion_item; visible: false;}
        }
    ]

    Image {
        id: image
        source: thumbnail
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 75
        height: 300
        //clip: true

        Rectangle{
            id: backdrop
            color: Material.background
            anchors.left: image.left
            anchors.right: image.right
            height: 75
            opacity: 0.25
        }

        Text {
            id: episodeText
            text: "Episode: " + episode_number + "\n" + episode_name
            color: Material.primary
            font.pointSize: 16
            //fontSizeMode: Text.Fit
            font.weight: Font.Black
            style: Text.Outline
            clip: true
            anchors.fill: parent
            anchors.margins: 10
            
        }
        Item{
            id: completion_item
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 64
            height: 64
            //visible: isWatched

            Image {
                id: image_complete
                source: "../assets/check_circle.png"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true
            }
            ColorOverlay {
                anchors.fill: image_complete
                source: image_complete
                color: Material.primary
            }
        }
    }
}