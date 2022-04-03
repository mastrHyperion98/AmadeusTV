from pickle import NONE
from PySide2.QtCore import QObject, Slot, Signal
from m3u8 import Playlist

from resources.crunchyroll_connect.utils import user

from ..crunchyroll_connect.server import CrunchyrollServer
from ..crunchyroll_connect.utils.types import Quality, Filters, Genres, Enum, RequestType
import json
import shelve
import os
import requests

def combine_string(delimeter, strings):
    combined = ""

    for s in strings:
        if combined == "":
            combined += s
        else: 
            combined += delimeter
            combined += s
    
    return combined


class ApplicationSettings():
    def __init__(self):
        self.init_store()
        self.completion = {}
        self.view_history = []

        self.init_completion()

    def init_store(self):
        if os.path.isfile('app.dat'):
            # File exists
            self.store = shelve.open('app.dat')

        else:
            store = shelve.open('app.dat')
            store['remember_me'] = False
            store['email'] = None
            store['password'] = None
            store['isLogin'] = False
            store['user_id'] = None
            store['isFirstTime'] = True
            # Both view history and completion will fetch from Amazon where data is stored by the cr user i
            self.store = store
    
    def getRememberMe(self):
        return self.store['remember_me']

    def isLogin(self):
        return self.store['isLogin']

    def isFirstTime(self):
        return self.store['isFirstTime']
    
    def setRememberMe(self, val):
        self.store['remember_me'] = val

    def setIsLogin(self, val):
       self.store['isLogin'] = val

    def setPassword(self, password):
        self.store['password'] = password

    def setEmail(self, email):
        self.store['email'] = email

    def setFirstTime(self, var):
        self.store['isFirstTime'] = var

    def setUserId(self, id):
        self.store['user_id'] = id

    def init_completion(self):
        if self.store['user_id'] is not None:
            url = "https://1kd8ybmavl.execute-api.us-east-1.amazonaws.com/"
            session = requests.Session()

            user_id=str(self.store['user_id'])

            data = {
                'user_id': user_id
            }

            req = session.get(url, params=data)
            content = req.json()

            print(req)
            if req.status_code == 200:
                self.completion = json.loads(content['collections'])
            
            print(self.completion)

            session.close()

    def addViewHistory(self, episode):
        self.view_history.append((episode.collection_id,episode.media_id))
        # Write to S3 / AWS

    def setCompleted(self, episode):
        if episode.collection_id in self.completion:
            if episode.media_id not in self.completion[episode.collection_id]:
                self.completion[episode.collection_id].append(episode.media_id)
                print(f'{episode.name} completed')
                # Write to S3 / AWS
        else: 
            self.completion[episode.collection_id] = []
            self.completion[episode.collection_id].append(episode.media_id)
            print(f'{episode.name} completed')
        
        print(self.completion)
    
    def updateS3Log(self):
        if self.store['user_id'] is not None:
            url = "https://1kd8ybmavl.execute-api.us-east-1.amazonaws.com/"
            session = requests.Session()

            user_id=str(self.store['user_id'])

            data = {
                'user_id': user_id,
                'collections': self.completion
            }

            req = requests.put(url, json=data)
            content = req.json()

            if req.status_code == 200:
                print("Pushed Completion records to AWS")

            session.close()
        

class CrunchyrollController(QObject):
    def __init__(self, limit=10):
        QObject.__init__(self)


        self.crunchyroll = CrunchyrollServer()
        self.crunchyroll.create_session()
        self.settings = ApplicationSettings()
        if self.settings.isLogin():
            self.crunchyroll.login()

        self.limit = 20

        self.playlist = []
        self.current = 0

    
    setSource = Signal(str)
    setHeader = Signal(str, str)
    setQuality = Signal(str)

    #Signals
    addSimulcast = Signal(str, str)

    #Signals
    addUpdated = Signal(str, str)

    addQueue = Signal(str, str)

    addSearch = Signal(str, str)
    startup = Signal(str)
    login = Signal(bool)
    logout = Signal()
    getRememberMe = Signal(str,str)
    #use json string emit all episodes
    getEpisodes = Signal(str)
    getCollections = Signal(str)
    searching = Signal()
    alert = Signal(str)


    @Slot()
    def setStartup(self):
        is_logged_in = self.settings.isLogin()
        is_remember_me = self.settings.getRememberMe()
        is_first_time = self.settings.isFirstTime()
        email = self.settings.store['email']
        password = self.settings.store['password']

        data = {"login": is_logged_in, 
                "is_remember_me": is_remember_me,
                "first_time": is_first_time,
                }

        json_data = json.dumps(data)
        self.startup.emit(json_data)
        
    @Slot(bool)
    def setRememberMe(self, val):
        self.settings.setRememberMe(val)
        self.settings.store.sync()

    @Slot()
    def getCreds(self):
        email = self.settings.store['email']
        password = self.settings.store['password']
        self.getRememberMe.emit(email,password)

    @Slot()
    def startSession(self):
        self.crunchyroll.create_session()

    # Maybe do some decoding so that values can't be intercepted
    @Slot(str, str)
    def setLogin(self, email, password):
        try:
            self.crunchyroll.login(email, password)
            user_id = self.crunchyroll.settings.store['user'].user_id
            self.settings.setEmail(email)
            self.settings.setPassword(password)
            self.settings.setIsLogin(True)
            self.settings.setUserId(user_id)
            self.settings.init_completion()

            if self.settings.isFirstTime():
                self.settings.setFirstTime(False)
            self.settings.store.sync()
            self.login.emit(True)
        except Exception as ex:
            print(ex)
            self.login.emit(False)
            self.alert.emit("Login Error: Invalid email and password combination !")

    @Slot()
    def cr_logout(self):
        print("LOGOUT")
        self.crunchyroll.logout()
        self.settings.setIsLogin(False)
        self.logout.emit()

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
    def search(self, q):
        simulcast = self.crunchyroll.search(q, 'anime', limit=100)
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
        self.playlist.clear()
        collections = self.crunchyroll.get_collections(series_id)
        json_collections = []

        for collection in collections: 
            name = collection.name
            series_id = collection.series_id
            collection_id = collection.collection_id
            availability = collection.availability

            json_def = {
                "name": name, 
                "series_id": series_id,
                "collection_id": collection_id, 
                "availability": availability
            }

            json_collections.append(json_def)

        json_collections = json.dumps(json_collections)
        self.getCollections.emit(json_collections)

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

            isWatched = False
            completion_list = self.settings.completion
            if collection_id in completion_list and media_id in completion_list[collection_id]:
                isWatched = True

            json_def = {
                "name": name,
                "episode_number": episode_number,
                "collection_id": collection_id,
                "series_id": series_id,
                "thumbnail": thumbnail,
                "media_id": media_id,
                "isWatched": False
            }
            json_episodes.append(json_def)

        json_episodes = json.dumps(json_episodes)
        self.getEpisodes.emit(json_episodes)

    @Slot(str)
    def fetchEpisodeList(self, collection_id):
        self.playlist.clear()
        episodes = self.crunchyroll.get_episodes(collection_id)
        json_episodes = []
        for episode in episodes:
            name = episode.name
            episode_number = episode.episode_number
            collection_id = collection_id
            series_id = episode.series_id
            thumbnail = episode.screenshot_image['large_url']
            media_id = episode.media_id

            isWatched = False
            completion_list = self.settings.completion
            if collection_id in completion_list and media_id in completion_list[collection_id]:
                isWatched = True


            json_def = {
                "name": name,
                "episode_number": episode_number,
                "collection_id": collection_id,
                "series_id": series_id,
                "thumbnail": thumbnail,
                "media_id": media_id,
                "isWatched": isWatched
            }
            json_episodes.append(json_def)

        json_episodes = json.dumps(json_episodes)
        self.getEpisodes.emit(json_episodes)

    @Slot(str, str, str, str)
    def addMediaToPlaylist(self, media_id, name, episode_num, collection_id):
        self.playlist.append(Episode(name, episode_num, media_id, collection_id))

    @Slot(int)
    def setPlaylistIndex(self, index):
        if index < len(self.playlist):
            self.current = index


    @Slot()
    def getCurrent(self):
        episode = self.playlist[self.current]
        self.settings.addViewHistory(episode)
        try:
            episode.getStream(self.crunchyroll)
        except Exception as ex:
            self.alert.emit("Error loading video stream - may not have access to this content !")

        self.setSource.emit(episode.stream[Quality.ULTRA.value].url)
        self.setHeader.emit(episode.name, episode.episode_num)

    """
    Get Next Fetches the next episode and marks the current episode as being completed. 
    More granular control to the definition of completed may be introduced later. but for 
    now simplicity is king. 
    """
    @Slot()
    def getNext(self):
        self.settings.setCompleted(self.playlist[self.current])
        
        if 0<= self.current < len(self.playlist):
            self.current += 1

        episode = self.playlist[self.current]
        self.settings.addViewHistory(episode)

        try:
            episode.getStream(self.crunchyroll)
        except Exception as ex:
            self.alert.emit("Error loading video stream - may not have access to this content !")

        self.setSource.emit(episode.stream[Quality.ULTRA.value].url)
        self.setHeader.emit(episode.name, episode.episode_num)

    @Slot()
    def getPrev(self):
        if self.current > 0:
            self.current -= 1
        
        episode = self.playlist[self.current]
        self.settings.addViewHistory(episode)
        try:
            episode.getStream(self.crunchyroll)
        except Exception as ex:
            self.alert.emit("Error loading video stream - may not have access to this content !")

        self.setSource.emit(episode.stream[Quality.ULTRA.value].url)
        self.setHeader.emit(episode.name, episode.episode_num)

    @Slot()
    def getUltra(self):
        self.setQuality.emit(self.playlist[self.current].stream[Quality.ULTRA.value].url)

    @Slot()
    def getHigh(self):
        self.setQuality.emit(self.playlist[self.current].stream[Quality.HIGH.value].url)

    @Slot()
    def getMedium(self):
        self.setQuality.emit(self.playlist[self.current].stream[Quality.MID.value].url)
    
    @Slot()
    def getLow(self):
        self.setQuality.emit(self.playlist[self.current].stream[Quality.LOW.value].url)
    
    @Slot()
    def getLowest(self):
        self.setQuality.emit(self.playlist[self.current].stream[Quality.LOWEST.value].url)
    
    def updateHistory(self, current):
        self.settings.addViewHistory(current.media_id)

class Episode():
    def __init__(self, name, episode_num, media_id, collection_id):
        self.name = name
        self.episode_num = episode_num
        self.media_id = media_id
        self.collection_id = collection_id
        self.stream_data = None

    def getStream(self, crunchyroll):
        if self.stream_data is None: 
            stream_data = crunchyroll.get_media_stream(self.media_id)
            self.stream = stream_data



