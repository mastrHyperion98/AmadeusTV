import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.0
import QtQuick.Controls.Styles 1.4

ApplicationWindow{
    id: window
    width: 1280
    height: 720
    visible: true
    color: "black"

    Item{
        Text {
            text: "Hello World"
            color: "White"
        }
    }
}