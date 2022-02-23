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
    maximumWidth: Screen.desktopAvailableWidth
    maximumHeight: Screen.desktopAvailableHeight
    width: 1280
    height: 720
    visible: true
    color: Material.accent

    Material.theme: Material.Dark
    Material.accent: Material.Pink
    Material.primary: Material.Purple

    header: SearchBar {
        height: 60
    }
    ScrollView{
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
            color: Material.accent

            ListModel {
                id: model
                ListElement {
                    name: "Re: Zero"
                    icon: "https://img1.ak.crunchyroll.com/i/spire1/653fb1c89ecec17dc6947308819d702b1610403801_full.jpg"
                }
                ListElement{
                    name: "ReLIFE"
                    icon: "https://img1.ak.crunchyroll.com/i/spire1/a539b8042cd8271f3d4768b9eeebbdc81465708253_full.jpg"
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

                        Text {
                            id: nameText
                            text: name
                            color: Material.accent
                            font.pointSize: 20
                            //fontSizeMode: Text.Fit
                            font.weight: Font.Bold
                            style: Text.Raised
                            styleColor: Material.primary
                            clip: true
                            anchors.fill: parent
                            anchors.margins: 10
                        }
                    }
                }
            }


            Rectangle{
                id: queue
                width: parent.width
                height: 500
                color: Material.background
                border.color: Material.accent
                border.width: 10
                

                Label {
                    id: queue_label
                    text: "Watch List"
                    color: Material.accent
                    font.pointSize: 20
                    //fontSizeMode: Text.Fit
                    font.weight: Font.Bold
                    style: Text.Raised
                    styleColor: Material.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                    padding: 15
                }

                ListView {
                    id: queueview
                    anchors.fill: parent
                    anchors.top: queue_label.bottom
                    anchors.topMargin: 50
                    model: model
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
                border.color: Material.accent
                border.width: 10

                Label {
                    id: simulcast_label
                    text: "Simulcasts"
                    color: Material.accent
                    font.pointSize: 20
                    //fontSizeMode: Text.Fit
                    font.weight: Font.Bold
                    style: Text.Raised
                    styleColor: Material.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                    padding:15
                }

                ListView {
                    anchors.fill: parent
                    model: model
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
                border.color: Material.accent
                border.width: 10

                Label {
                    id: updated_label
                    text: "Updated"
                    color: Material.accent
                    font.pointSize: 20
                    //fontSizeMode: Text.Fit
                    font.weight: Font.Bold
                    style: Text.Raised
                    styleColor: Material.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                    padding: 15
                }

                ListView {
                    anchors.fill: parent
                    model: model
                    delegate: delegate
                    orientation: ListView.Horizontal
                    anchors.top: updated_label.bottom
                    anchors.topMargin: 50
                }
            }

        }
    }
}
