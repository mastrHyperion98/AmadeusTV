import sys
import os
import atexit
import platform
import pathlib
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

    os.environ['QT_QPA_PLATFORM'] = 'xcb'
    platform_release = platform.release()
    is_deck = False
    if platform_release.__contains__('valve'):
        is_deck = True
    print(f'Platform is Deck: {is_deck}' )
    
    # Get absolute path to qml main file
    current_path = pathlib.Path(__file__).parent.absolute()
    qml_path = os.path.join('current_path','qml', 'main.qml')
    #Create our Application
    app = QGuiApplication()
    app.setApplicationDisplayName("Amadeus TV")
    #app.setWindowIcon(QIcon("assets/icons-tv-64.png"))
    QQuickStyle.setStyle("Material")
    engine = QQmlApplicationEngine()
    backend = CrunchyrollController(150)
    atexit.register(exit_handler, backend)
    engine.rootContext().setContextProperty("backend", backend)
    engine.setInitialProperties(
        {
        "is_deck": is_deck
        }
    )
    engine.load("qml/main.qml")
    #Exit application properly
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())