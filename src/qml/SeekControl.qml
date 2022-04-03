import QtQuick 2.15
import QtQuick.Controls 2.15
Item {
    id: root

    property int position: 0
    property int duration: 0
    property alias pressed : seekSlider.pressed
    property bool enabled: true


    onPositionChanged: {
        elapsedText.text = formatTime(position);
        seekSlider.value = position;
    }

    onDurationChanged: {
        remainingText.text = formatTime(duration);
    }

    Text {
        id: elapsedText
        anchors.verticalCenter: root.verticalCenter
        anchors.left: root.left
        text: "00:00:00"
        color: "white"
    }

    Slider {
        id: seekSlider
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.left: elapsedText.right
        anchors.right: remainingText.left
        anchors.verticalCenter: root.verticalCenter
        enabled: root.enabled
        from: 0
        to: duration
        value: 0
        stepSize: 10000
        snapMode: Slider.SnapOnRelease
        live: false
    }

    Text {
        id: remainingText
        anchors.verticalCenter: root.verticalCenter
        anchors.right: root.right
        text: "00:00:00"
        color: "white"
    }

    function formatTime(time) {
        time = time / 1000
        var hours = Math.floor(time / 3600);
        time = time - hours * 3600;
        var minutes = Math.floor(time / 60);
        var seconds = Math.floor(time - minutes * 60);

        return formatTimeBlock(hours) + ":" + formatTimeBlock(minutes) + ":" + formatTimeBlock(seconds);

    }

    function formatTimeBlock(time) {
        if (time === 0)
            return "00"
        if (time < 10)
            return "0" + time;
        else
            return time.toString();
    }

    Connections{
        target: seekSlider

        function onMoved(){
            if(player.seekable){
                var newPos = seekSlider.value;
                player.seek(newPos);  
            }
        }
    }
}
