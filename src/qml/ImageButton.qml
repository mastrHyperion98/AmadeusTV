import QtQuick 2.15
import QtGraphicalEffects 1
import QtQuick.Controls.Material 2.15

Item {
    id: item_root
    property alias enabled: mouseArea.enabled
    property alias imageSource: image.source

    property bool checkable: false
    property bool checked: false
    property alias hover: mouseArea.containsMouse
    property alias pressed: mouseArea.pressed

    opacity: enabled ? 1.0 : 0.5
    signal clicked

    width: image.width
    height: 24

    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: true
        
    }

    ColorOverlay {
        id: glowEffect
        anchors.fill: image
        source: image
        color: hover ? Material.accent : Material.foreground
        visible: checked || hover || pressed
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: item_root
        onClicked:{
            item_root.clicked();
            //checked = !checked;
        } 

    }
}