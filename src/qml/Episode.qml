import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15

Rectangle{
    id: root
    property var thumbnail: ""
    property var episode_id: ""
    property var episode_name: ""
    property var episode_number: 0
    property alias nameColor: episode_name_id.color

    width: 750
    height: 150
    color: Material.background

    Image {
        id: image
        source: thumbnail
        clip: true

        Rectangle{
            id: backdrop
            color: Material.background
            width: parent.width
            height: 75
            opacity: 0.25
        }

        Text {
            id: episodeText
            text: "Episode: " + episode_number
            color: Material.primary
            font.pointSize: 16
            //fontSizeMode: Text.Fit
            font.weight: Font.Black
            style: Text.Outline
            clip: true
            anchors.fill: parent
            anchors.margins: 10
            
        }
    }

    Rectangle{
        id: nameContent
        height: 150
        anchors.top: parent.top 
        anchors.left: image.right
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 10
        color: Material.background

        Text {
            id: episode_name_id
            text: episode_name
            font.pointSize: 16
            color: Material.primary
            font.weight: Font.Black
            style: Text.Outline
            wrapMode: Text.Wrap
            anchors.fill: parent
        }
    }
}