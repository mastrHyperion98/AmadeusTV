from PySide2.QtCore import QObject, Slot, Signal

from lib.crunchyroll_connect.server import CrunchyrollServer
from lib.crunchyroll_connect.utils.types import Quality, Filters, Genres, Enum, RequestType
import json

def combine_string(delimeter, strings):
    combined = ""

    for s in strings:
        if combined == "":
            combined += s
        else: 
            combined += delimeter
            combined += s
    
    return combined



class CrunchyrollController(QObject):
    def __init__(self, limit=10):
        QObject.__init__(self)
        creds = {
            "account": "placeholder",
            "password": "placeholder"
        }
        self.crunchyroll = CrunchyrollServer()
        self.crunchyroll.create_session()
        self.crunchyroll.login(creds['account'], creds['password'])
        self.limit = 10


    #Signals
    addSimulcast = Signal(str, str)

    #Signals
    addUpdated = Signal(str, str)

    addQueue = Signal(str, str)

    addSearch = Signal(str, str)

    #use json string emit all episodes
    fetchEpisodes = Signal(str)

    searching = Signal()

    @Slot()
    def getSimulcast(self):
        simulcast = self.crunchyroll.filter_series(limit=self.limit, offset=0, filter_type = Filters.SIMULCAST)

        data = []
        for series in simulcast: 
            img = series.landscape_image['full_url']
            name = series.name
            id = series.series_id
            description = series.description
            portrait_img = series.portrait_image['large_url']

            data = {
                "id": id,
                "name": name,
                "description": description,
                "portrait_icon": portrait_img
            }

            json_data = json.dumps(data)
            self.addSimulcast.emit(json_data , img)

    @Slot()
    def getUpdated(self):
        simulcast = self.crunchyroll.filter_series(limit=self.limit, offset=0, filter_type = Filters.UPDATED)

        for series in simulcast: 
            img = series.landscape_image['full_url']
            name = series.name
            id = series.series_id
            description = series.description
            portrait_img = series.portrait_image['large_url']

            data = {
                "id": id,
                "name": name,
                "description": description,
                "portrait_icon": portrait_img
            }

            json_data = json.dumps(data)
            self.addUpdated.emit(json_data, img)


    @Slot(str)
    def search(self, prefix):
        simulcast = self.crunchyroll.filter_series(limit=100, offset=0, filter_type = Filters.PREFIX, filter_tag=prefix)
        self.searching.emit()
        for series in simulcast: 
            img = series.landscape_image['full_url']
            name = series.name
            id = series.series_id
            description = series.description
            portrait_img = series.portrait_image['full_url']

            data = {
                "id": id,
                "name": name,
                "description": description,
                "portrait_icon": portrait_img
            }

            json_data = json.dumps(data)
            self.addSearch.emit(json_data, img)

    @Slot(str)
    #Get list of collection and return first collection episodes info
    def fetchCollections(self, series_id):
        collections = self.crunchyroll.get_collections(series_id)
        json_collections = []

        for collection in collections: 
            name = collection.name
            series_id = collection.series_id
            collection_id = collection.collection_id
            availability = collection.availability

            json_def = {"name": name, 
            "series_id": series_id,
            "collection_id": collection_id, 
            "availability": availability}

            json_collections.append(json_def)

        default = collections[0]
        json_episodes = []
        episodes = self.crunchyroll.get_episodes(default.collection_id)

    
        for episode in episodes:
            name = episode.name
            episode_number = episode.episode_number
            collection_id = default.collection_id
            series_id = episode.series_id
            thumbnail = episode.screenshot_image['large_url']
            media_id = episode.media_id

            json_def = {
                "name": name,
                "episode_number": episode_number,
                "collection_id": collection_id,
                "series_id": series_id,
                "thumbnail": thumbnail,
                "media_id": media_id
            }
            json_episodes.append(json_def)

        json_episodes = json.dumps(json_episodes)
        #print(json_episodes)
        #self.fetchCollections.emit(json_collections)
        self.fetchEpisodes.emit(json_episodes)


