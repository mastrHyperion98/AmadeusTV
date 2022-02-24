from PySide2.QtCore import QObject, Slot, Signal
from lib.crunchyroll_connect.server import CrunchyrollServer
from lib.crunchyroll_connect.utils.types import Quality, Filters, Genres, Enum, RequestType


class CrunchyrollController(QObject):
    def __init__(self, limit=10):
        QObject.__init__(self)
        self.crunchyroll = CrunchyrollServer()
        self.crunchyroll.create_session()
        self.limit = 10


    #Signals
    addSimulcast = Signal(str, str)

    #Signals
    addUpdated = Signal(str, str)

    addQueue = Signal(str, str)

    addSearch = Signal(str, str)

    searching = Signal()

    @Slot()
    def getSimulcast(self):
        simulcast = self.crunchyroll.filter_series(limit=self.limit, offset=0, filter_type = Filters.SIMULCAST)

        for series in simulcast: 
            img = series.landscape_image['full_url']
            name = series.name
            id = series.series_id
            uuid = f'{name}__UUID__{id}'
            #tup.append(name)
            self.addSimulcast.emit(uuid, img)

    @Slot()
    def getUpdated(self):
        simulcast = self.crunchyroll.filter_series(limit=self.limit, offset=0, filter_type = Filters.UPDATED)

        for series in simulcast: 
            img = series.landscape_image['full_url']
            name = series.name
            id = series.series_id
            uuid = f'{name}__UUID__{id}'
            #tup.append(name)
            self.addUpdated.emit(uuid, img)


    @Slot(str)
    def search(self, prefix):
        simulcast = self.crunchyroll.filter_series(limit=100, offset=0, filter_type = Filters.PREFIX, filter_tag=prefix)
        self.searching.emit()
        print("searching")
        count = 0
        for series in simulcast: 
            img = series.landscape_image['full_url']
            name = series.name
            id = series.series_id
            uuid = f'{name}__UUID__{id}'
            #To Change
            self.addSearch.emit(uuid, img)
            count += 1

        print(count)


