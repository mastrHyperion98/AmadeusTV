import sys
import os
import atexit
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtQuickControls2 import QQuickStyle
from resources.controllers.crunchyroll_controller import CrunchyrollController

VERSION = "0.0.1"
APPLICATION_NAME =  "AMADEUS_TV"
AUTHOR = "mastrhyperion98"


def exit_handler(backend):
    #Properly close the crunchyroll server
    backend.close()

if __name__ == "__main__":
    
    print("{} v{} by {}".format(APPLICATION_NAME, VERSION, AUTHOR))
    os.environ['QT_MULTIMEDIA_PREFERRED_PLUGINS']='mdk'
    
    # Get absolute path to qml main file
    current_path = os.path.dirname(os.path.abspath(__file__))
    print(current_path)
    qml_path = os.path.join('qml', 'main.qml')
    #Create our Application
    app = QGuiApplication()
    app.setApplicationDisplayName("Amadeus TV")
    #app.setWindowIcon(QIcon("assets/icons-tv-64.png"))
    QQuickStyle.setStyle("Material")
    engine = QQmlApplicationEngine()
    backend = CrunchyrollController(15)
    atexit.register(exit_handler, backend)
    engine.rootContext().setContextProperty("backend", backend)
    engine.load(qml_path)
    #Exit application properly
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())