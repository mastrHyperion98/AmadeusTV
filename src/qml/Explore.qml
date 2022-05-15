import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.4
import QtQuick.Controls.Material 2.15

Rectangle{
    objectName: "Explore"
    color: Material.background
    property int numCol: parent.width / 400;
    property double heightMultiplier: 240 / parent.height

    GridView{
        id: explore
        model: explore_model
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
        id: explore_model
        ListElement {
            name: "Action"
            img: "https://img1.ak.crunchyroll.com/i/spire1/c07c539a9b3fb07ed04f9adbbaa67cb81633316825_full.jpg"
        }
        ListElement {
            name: "Adventure"
            img: "https://img1.ak.crunchyroll.com/i/spire3/0057eca3f078f08bb9c35193ce49e7821641869272_full.jpg"
        }
        ListElement {
            name: "Comedy"
            img: "https://img1.ak.crunchyroll.com/i/spire3/917cf746b275ffec3daf62b433ccf4a81582670947_full.jpg"
        }
        ListElement {
            name: "Drama"
            img: "https://img1.ak.crunchyroll.com/i/spire4/f11343ee2063b33659b500de304b87a51412797512_full.jpg"
        }
        ListElement {
            name: "Fantasy"
            img: "https://img1.ak.crunchyroll.com/i/spire4/f7c73276f16f5ebdf25524cae91c00a11414524142_full.jpg"
        }
        ListElement {
            name: "Harem"
            img: "https://img1.ak.crunchyroll.com/i/spire4/010634e9d1c76f0596248c1091e4586c1610403543_full.jpg"
        }
        ListElement {
            name: "Historical"
            img: "https://img1.ak.crunchyroll.com/i/spire2/41164170cf7752cd537253cf188c2f141420502308_full.jpg"
        }
        ListElement {
            name: "Idols"
            img: "https://img1.ak.crunchyroll.com/i/spire4/5b917af1f865df5c4f8bf3ae7f3bd6df1618246626_full.jpg"
        }
        ListElement {
            name: "Isekai"
            img: "https://img1.ak.crunchyroll.com/i/spire2/9139c255aa197b8e829703d83763cf211396985146_full.jpg"
        }
        ListElement {
            name: "Magical Girls"
            img: "https://img1.ak.crunchyroll.com/i/spire3/814f705ef0f98033fddba15afdb69f961329513480_full.png"
        }
        ListElement {
            name: "Mecha"
            img: "https://img1.ak.crunchyroll.com/i/spire4/fa2678f5e7b51c0a35c755245d9f894b1420484059_full.jpg"
        }
        ListElement {
            name: "Music"
            img: "https://img1.ak.crunchyroll.com/i/spire2/ec0cf76989d51b006bebe04013f61fc71477942257_full.jpg"
        }
        ListElement {
            name: "Mystery"
            img: "https://img1.ak.crunchyroll.com/i/spire2/05fac5f2e0957f6ec182c9135aebe0b61326142125_full.jpg"
        }
        ListElement {
            name: "Post-Apocalyptic"
            img: "https://img1.ak.crunchyroll.com/i/spire1/a323bff08a4d09dfacced8bb63ed53151348858762_full.jpg"
        }
        ListElement {
            name: "Romance"
            img: "https://img1.ak.crunchyroll.com/i/spire1/c50799b6f3b2f6febe340e3da4fc8d1d1492038532_full.jpg"
        }
        ListElement {
            name: "Sci-Fi"
            img: "https://img1.ak.crunchyroll.com/i/spire2/6868a8f9893b2030fce1e4a4bb461f751523422282_full.jpg"
        }
        ListElement {
            name: "Seinen"
            img: "https://img1.ak.crunchyroll.com/i/spire1/a1b9e0783210f940b383626b224e88271422401582_full.jpg"
        }
        ListElement {
            name: "Shojo"
            img: "https://img1.ak.crunchyroll.com/i/spire2/e867cabc749a1b7ae05238cce77294231259909627_full.jpg"
        }
        ListElement {
            name: "Shonen"
            img: "https://img1.ak.crunchyroll.com/i/spire1/5a178ace09f0fac780b758a7e231db631510871407_full.jpg"
        }
        ListElement {
            name: "Slice of Life"
            img: "https://img1.ak.crunchyroll.com/i/spire1/a539b8042cd8271f3d4768b9eeebbdc81465708253_full.jpg"
        }
        ListElement {
            name: "Sports"
            img: "https://img1.ak.crunchyroll.com/i/spire4/0fd6f9106aacd56a91af9533c2783f4f1580166619_full.jpg"
        }
        ListElement {
            name: "Supernatural"
            img: "https://img1.ak.crunchyroll.com/i/spire4/609193ffc9118c7c31cd735fa4a4b6f61619462688_full.jpg"
        }
        ListElement {
            name: "Thriller"
            img: "https://img1.ak.crunchyroll.com/i/spire4/a688f25e96164d38f6892d38192843dd1606767553_full.jpg"
        }
    }

    Component {
        id: delegate
        Column {
            id: wrapper
            padding: 10
            Image {
                id: image
                source: img
                clip: true
                width: explore.cellWidth - 20
                height: explore.cellHeight - 40

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
                          main.push("SearchResult.qml");
                          backend.explore(name);
                      } 
                   }
            }
        }
    }

    Connections {
        target: backend
    }
}