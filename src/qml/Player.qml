import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.15
Rectangle {
    id: root
    //anchors.fill: parent
    color: "black"
    property bool isFullscreen: false
    property bool isSettingsOpen: false
    property int playback_position: 0


    MouseArea {
        id: mouseActivityMonitor
        anchors.fill: parent

        hoverEnabled: true
        onPositionChanged: {
            controlBar.show();
            videoHeader.show();
            controlBarTimer.restart();
        }
    }

    signal resetTimer
    onResetTimer: {
        controlBar.show();
        videoHeader.show();
        controlBarTimer.restart();
    }

    Timer {
        id: controlBarTimer
        interval: 5000
        running: false

        onTriggered: {
            hideToolBars();
        }
    }

    MediaPlayer {
        id: player
        volume: volumeSlider.value
    }
    
    VideoOutput {
        id: videoOutput
        width: root.width
        height: root.height
        anchors.horizontalCenter: parent.horizontalCenter
        source: player
    }

    Rectangle {
        id: controlBar
        //source: "../assets/ControlBar.png"
        height: 70
        width: root.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#33000000"

        property bool isMouseAbove: false

        MouseArea {
            anchors.fill: controlBar
            hoverEnabled: true

            onEntered: controlBar.isMouseAbove = true;
            onExited: {
                controlBar.isMouseAbove = false;
            }
        }

        state: "VISIBLE"

        SeekControl {
            id: seekControl
            anchors.bottom: previous_button.top
            anchors.topMargin: 13
            anchors.right: controlBar.right
            anchors.left: controlBar.left
            anchors.rightMargin: 15
            anchors.leftMargin: 15
            anchors.bottomMargin: 15

            duration: player.duration
        }

        ImageButton {
            id: previous_button
            imageSource: "../assets/previous.png"

            //text: player.playbackState === MediaPlayer.PlayingState ? qsTr("Pause"): qsTr("Play")
            onClicked: {
                backend.getPrev();
            }
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 15
        }

        ImageButton {
            id: play_button
            imageSource: player.playbackState === MediaPlayer.PlayingState ? "../assets/pause.png": "../assets/play.png"

            //text: player.playbackState === MediaPlayer.PlayingState ? qsTr("Pause"): qsTr("Play")

            onClicked: {
                if (player.status ==  MediaPlayer.Stalled)
                    return
                switch(player.playbackState){
                    case MediaPlayer.PlayingState: player.pause(); break;
                    case MediaPlayer.PausedState: player.play(); break;
                    case MediaPlayer.StoppedState: player.play(); break;
                }
            }
            anchors.left: previous_button.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 15
            anchors.leftMargin: 60
        }

        ImageButton {
            id: next_button
            imageSource: "../assets/next.png"

            //text: player.playbackState === MediaPlayer.PlayingState ? qsTr("Pause"): qsTr("Play")
            onClicked: {
                backend.getNext();
            }
            anchors.left: play_button.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 15
            anchors.leftMargin: 60
        }

        ImageButton {
            id: volume_button
            imageSource: player.muted ? "../assets/mute.png": "../assets/volume_on.png"

            //text: player.playbackState === MediaPlayer.PlayingState ? qsTr("Pause"): qsTr("Play")
            onClicked: {
                player.muted = !player.muted
            }

            anchors.left: next_button.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 15
            anchors.leftMargin: 60
        }

        Slider {
            id: volumeSlider
            anchors.left: volume_button.right
            anchors.leftMargin: 20
            anchors.verticalCenter: controlBar.verticalCenter
            from: 0.
            to: 1.
            value: 0.50
            stepSize: 0.10
            live: true
            width: 125
        }

        ImageButton {
            id: videoSettings
            imageSource:  "../assets/settings.png"
            onClicked: {
                if (isSettingsOpen){
                    videoOptions.opacity = 0
                    isSettingsOpen = false
                }
                else{
                    isSettingsOpen = true
                    videoOptions.opacity =1
                } 
                    
            }
            anchors.right: fullscreenButton.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 15
        }

        Rectangle {
            id: videoOptions
            height: 100
            anchors.left: videoSettings.left
            anchors.bottom: parent.top
            width: 250
            color: "#33000000"
            opacity: 0


            Grid{
                columns: 2
                rows: 2
                spacing: 10
                verticalItemAlignment: Grid.AlignVCenter
                topPadding: 20
                bottomPadding: 20

                Label {
                    id: qualityLabel
                    text: "Quality"
                    color: "white"
                    font.pixelSize: 14
                }
                
                ComboBox {
                    id: qualityCB
                    currentIndex: 0
                    model: [ "AUTO", "1080p", "720p", "480p", "360p"]

                    //the background of the combobox
                    background: Rectangle {
                        color: Material.accent
                        border.color: "white"
                        radius: height/2
                    }

                    delegate: ItemDelegate {
                        id:itemDlgt
                        width: qualityCB.width
                        height:40

                        contentItem: Text {id:textItem
                            text: modelData
                            color: hovered?"white":Material.primary
                            font: qualityCB.font
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                        }

                        background: Rectangle {
                            radius: 20
                            color:itemDlgt.hovered? Material.accent:"white";
                            anchors.left: itemDlgt.left
                            anchors.leftMargin: 0
                            width:itemDlgt.width-2
                        }
                    }

                    //the text in the combobox
                    contentItem: Text {
                            leftPadding: 20
                            rightPadding: qualityCB.indicator.width + qualityCB.spacing

                            text: qualityCB.displayText
                            font: qualityCB.font
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                    }

                    //the list of elements and their style when the combobox is open
                    popup: Popup {
                            id:comboPopup
                            y: qualityCB.height - 1
                            width: qualityCB.width
                            height:contentItem.implicitHeigh
                            padding: 1

                            contentItem: ListView {
                                id:listView
                                implicitHeight: contentHeight
                                model: qualityCB.popup.visible ? qualityCB.delegateModel : null

                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                radius: 20
                                border.width: 1
                                border.color:"#95A4A8"
                            }
                        }

                    onActivated: {
                        var quality = currentText
                        switch(quality){
                            case "1080p":
                                backend.getUltra();
                                break;
                            case "720p":
                                backend.getHigh();
                                break;
                            case "480p":
                                backend.getMedium();
                                break;
                            case "360p":
                                backend.getLow();
                                break;
                            case "240p":
                                backend.getLowest();
                                break;
                            case "AUTO":
                                backend.getHigh();
                                break;
                    } 
                    }
                }

                Label {
                    id: speedLabel
                    text: "Speed"
                    color: "white"
                    font.pixelSize: 14
                }

                ComboBox {
                    id: speedCB
                    currentIndex: 2
                    model: [ "0.25", "0.5", "1.0", "1.5", "2.0" ]
                    background: Rectangle {
                            color: Material.accent
                            border.color: "white"
                            radius: height/2
                        }

                    delegate: ItemDelegate {
                        id:itemDlgt_speed
                        width: speedCB.width
                        height:40

                        contentItem: Text {id:textItem_speed
                            text: modelData
                            color: hovered?"white":Material.primary
                            font: speedCB.font
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                        }

                        background: Rectangle {
                            radius: 20
                            color:itemDlgt_speed.hovered?Material.accent:"white";
                            anchors.left: itemDlgt_speed.left
                            anchors.leftMargin: 0
                            width:itemDlgt_speed.width-2
                        }
                    }

                    //the text in the combobox
                    contentItem: Text {
                            leftPadding: 20
                            rightPadding: speedCB.indicator.width + speedCB.spacing

                            text: speedCB.displayText
                            font: speedCB.font
                            color: "white"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                    }

                    //the list of elements and their style when the combobox is open
                    popup: Popup {
                            id:comboPopup_speed
                            y: speedCB.height - 1
                            width: speedCB.width
                            height:contentItem.implicitHeigh
                            padding: 1

                            contentItem: ListView {
                                id:listView_speed
                                implicitHeight: contentHeight
                                model: speedCB.popup.visible ? speedCB.delegateModel : null

                                ScrollIndicator.vertical: ScrollIndicator { }
                            }

                            background: Rectangle {
                                radius: 20
                                border.width: 1
                                border.color:"#95A4A8"
                            }
                        }

                    onActivated: {
                        switch(currentIndex){
                            case 0:
                                player.playbackRate = Number(currentText)
                                break;
                            case 1:
                                player.playbackRate = Number(currentText)
                                break;
                            case 2:
                                player.playbackRate = Number(currentText)
                                break;
                            case 3:
                                player.playbackRate = Number(currentText)
                                break;
                            case 4:
                                player.playbackRate = Number(currentText)
                                break;
                    } 
                    }
                }
            }
        }
        ImageButton {
            id: fullscreenButton
            imageSource: window.isFullscreen ? "../assets/close_fullscreen.png":"../assets/enter_fullscreen.png"
            onClicked: {
                //Toggle fullscreen
                toggleFullScreen();
            }
            checkable: true

            checked: isFullscreen
            anchors.right: controlBar.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 15
        }

        function hide()
        {
            controlBar.state = "HIDDEN";
        }

        function show()
        {
            controlBar.state = "VISIBLE";
        }

        states: [
            State {
                name: "HIDDEN"
                PropertyChanges {
                    target: controlBar
                    opacity: 0.0
                }
            },
            State {
                name: "VISIBLE"
                PropertyChanges {
                    target: controlBar
                    opacity: 0.95
                }
            }
        ]
        transitions: [
            Transition {
                from: "HIDDEN"
                to: "VISIBLE"
                NumberAnimation {
                    id: showAnimation
                    target: controlBar
                    properties: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 200
                }
            },
            Transition {
                from: "VISIBLE"
                to: "HIDDEN"
                NumberAnimation {
                    id: hideAnimation
                    target: controlBar
                    properties: "opacity"
                    from: 0.95
                    to: 0.0
                    duration: 200
                }
            }
        ]
    }


    Rectangle {
        id: videoHeader
        //source: "../assets/ControlBar.png"
        height: 70
        width: root.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: "#33000000"

        property bool isMouseAbove: false

        MouseArea {
            anchors.fill:videoHeader
            hoverEnabled: true

            onEntered: videoHeader.isMouseAbove = true;
            onExited: {
                videoHeader.isMouseAbove = false;
            }
        }



        state: "VISIBLE"

        Text{
            id: video_text
            text: ""
            color: "white"
            font.pointSize: 18
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        function hide()
        {
            videoHeader.state = "HIDDEN";
        }

        function show()
        {
            videoHeader.state = "VISIBLE";
        }

        states: [
            State {
                name: "HIDDEN"
                PropertyChanges {
                    target: videoHeader
                    opacity: 0.0
                }
            },
            State {
                name: "VISIBLE"
                PropertyChanges {
                    target: videoHeader
                    opacity: 0.95
                }
            }
        ]

        transitions: [
            Transition {
                from: "HIDDEN"
                to: "VISIBLE"
                NumberAnimation {
                    id: showHeaderAnimation
                    target: videoHeader
                    properties: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 200
                }
            },
            Transition {
                from: "VISIBLE"
                to: "HIDDEN"
                NumberAnimation {
                    id: hideHeaderAnimation
                    target: videoHeader
                    properties: "opacity"
                    from: 0.95
                    to: 0.0
                    duration: 200
                }
            }
        ]
    }

    function toggleFullScreen()
    {
        if(!isFullscreen){
            window.showFullScreen();
            isFullscreen = true;
            window.header.visible = false;
        }
        else {
            window.showNormal();
            isFullscreen = false;
            window.header.visible = true;
        }
    }

    function hideToolBars(){
        if (!controlBar.isMouseAbove){
        controlBar.hide();
        videoHeader.hide();
        }
    }

    function setPlaybackPosition(){
        if(player.seekable && player.position < playback_position)
            player.seek(playback_position);
    }

    Connections {
        target: player

        function onPositionChanged() {
            if (!seekControl.pressed) 
                seekControl.position = player.position;
            setPlaybackPosition();

            if(player.duration > 0)
                if(player.position == player.duration){
                    backend.getNext();
                    player.play();
                }
        }

        // check when media is stalled
        // check when media is buffering
        function onStatusChanged(){
            if(player.status ==  MediaPlayer.Stalled){
                player.pause();
                console.log("Mediaplayer is stalled and is buffering");
                
            }

            else if(player.status == MediaPlayer.Buffered){
                player.play();
                console.log("Mediaplayer buffered was filled");
            }
        }

    }
    Connections {
        target: backend
        
        function onSetSource(source) {
            playback_position = 0;
            player.source = source ;
            player.play()
        }  

        function onSetHeader(name, number){
            video_text.text = "Episode " + number + " : " + name;
        }

        function onSetQuality(source){
            playback_position = player.position;
            player.source = source;
            player.play();
        }
    }
    // run things on start up
    Component.onCompleted: {
        backend.getCurrent();
    }
}