import sys
import os

from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtQuickControls2 import QQuickStyle


VERSION = "0.0.1"
APPLICATION_NAME =  "AMADEUS_TV"
AUTHOR = "mastrhyperion98"


if __name__ == "__main__":
    print("{} v{} by {}".format(APPLICATION_NAME, VERSION, AUTHOR))
    
    # Get absolute path to qml main file
    current_path = os.path.dirname(os.path.abspath(__file__))
    qml_path = os.path.join(current_path, 'qml', 'main.qml')
    #Create our Application
    app = QGuiApplication()
    QQuickStyle.setStyle("Material")
    engine = QQmlApplicationEngine()
    #engine.rootContext().setContextProperty("backend", backend)
    engine.load(qml_path)
    #Exit application properly
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())