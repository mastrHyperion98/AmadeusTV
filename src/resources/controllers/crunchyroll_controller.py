import json
from pickle import NONE
from PySide2.QtCore import QObject, Slot, Signal
from ..crunchyroll_connect.server import CrunchyrollServer
from ..crunchyroll_connect.utils.types import Quality, Filters, Genres, Enum, RequestType
from ..application_settings import ApplicationSettings

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


        self.crunchyroll = CrunchyrollServer()
        self.settings = ApplicationSettings()

        if self.settings.isLogin() or self.settings.getRememberMe():
            self.crunchyroll.login(self.settings.getEmail(), self.settings.getPassword())
        else:
            self.crunchyroll.create_session()

        self.limit = 20

        self.playlist = []
        self.current = 0

    #Signals
    setSource = Signal(str)
    setHeader = Signal(str, str)
    setQuality = Signal(str)
    addSimulcast = Signal(str, str)
    addUpdated = Signal(str, str)
    addQueue = Signal(str, str)
    addSearch = Signal(str, str)
    startup = Signal(str)
    login = Signal(bool)
    logout = Signal()
    getRememberMe = Signal(str,str)
    getEpisodes = Signal(str)
    getCollections = Signal(str)
    searching = Signal()
    alert = Signal(str)
    setWatched = Signal(str)


    @Slot()
    def setStartup(self):
        is_logged_in = self.settings.isLogin()
        is_remember_me = self.settings.getRememberMe()
        is_first_time = self.settings.isFirstTime()

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
            user = self.crunchyroll.login(email, password)
            user_id = self.crunchyroll.settings.store['user'].user_id
            self.settings.setEmail(email)
            self.settings.setPassword(password)
            self.settings.setIsLogin(True)
            self.settings.setUserId(user_id)

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
        #self.settings.updateS3Log()
        self.crunchyroll.logout()
        self.settings.completion = {}
        self.settings.view_history = []
        self.settings.setUserId(None)
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

        # if self.settings.store['user_id'] is not None:
        #         url = "https://1kd8ybmavl.execute-api.us-east-1.amazonaws.com/amadeus-tv-completion-get"
        #         session = requests.Session()

        #         user_id=str(self.settings.store['user_id'])

        #         data = {
        #             'user_id': user_id,
        #             'collection_id': default.collection_id
        #         }

        #         req = session.get(url, json=data)
        #         content = req.json()
        #         print("SQL QUERY!!!")
        #         print(content)
        #         if req.status_code == 200:
        #             print("SQL QUERY!!!")
        #             print(content)

        #         session.close()

    
        for episode in episodes:
            name = episode.name
            episode_number = episode.episode_number
            collection_id = default.collection_id
            series_id = episode.series_id
            thumbnail = episode.screenshot_image['full_url']
            media_id = episode.media_id

            isWatched = self.settings.is_completed(collection_id, media_id)

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

    @Slot(str)
    def fetchEpisodeList(self, collection_id):
        self.playlist.clear()
        episodes = self.crunchyroll.get_episodes(collection_id)
        json_episodes = []

        # if self.settings.store['user_id'] is not None:
        #         url = "https://1kd8ybmavl.execute-api.us-east-1.amazonaws.com/amadeus-tv-completion-get"
        #         session = requests.Session()

        #         user_id=str(self.settings.store['user_id'])

        #         data = {
        #             'user_id': user_id,
        #             'collection_id': collection_id
        #         }

        #         req = session.get(url, json=data)
        #         content = req.json()
        #         print("SQL QUERY!!!")
        #         print(content)
        #         if req.status_code == 200:
        #             print("SQL QUERY!!!")
        #             print(content)

        #         session.close()
        
        for episode in episodes:
            name = episode.name
            episode_number = episode.episode_number
            collection_id = collection_id
            series_id = episode.series_id
            thumbnail = episode.screenshot_image['full_url']
            media_id = episode.media_id

            isWatched = self.settings.is_completed(collection_id, media_id)

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

    @Slot(int)
    def setCurrentPlayback(self, playhead):
        self.playlist[self.current].setPlayhead(playhead)
    
    @Slot(bool)
    def setCurrentCompleted(self, completed):
        self.playlist[self.current].setCompleted(completed)
        self.setWatched.emit(self.playlist[self.current].media_id)

    @Slot()
    def logMedia(self):
        # url = "https://1kd8ybmavl.execute-api.us-east-1.amazonaws.com/"
        # user_id=str(self.settings.store['user_id'])

        # data = {
        #     'user_id': user_id,
        #     'collection_id': self.playlist[self.current].collection_id,
        #     'episode_id': self.playlist[self.current].media_id,
        #     'playhead': self.playlist[self.current].playhead,
        #     'completed': self.playlist[self.current].completed
        # }

        # req = requests.put(url, json=data)

        # if req.status_code == 200:
        if self.playlist[self.current].completed:
            self.settings.add_completed(self.playlist[self.current].collection_id,self.playlist[self.current].media_id)

        else:
            self.settings.add_view_history(self.playlist[self.current].collection_id,self.playlist[self.current].media_id)


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
        #self.settings.addViewHistory(episode)
        try:
            episode.getStream(self.crunchyroll)
        except Exception as ex:
            self.alert.emit("Error loading video stream - may not have access to this content !")

        self.setSource.emit(episode.stream_data[Quality.ULTRA.value].url)
        self.setHeader.emit(episode.name, episode.episode_num)

    """
    Get Next Fetches the next episode and marks the current episode as being completed. 
    More granular control to the definition of completed may be introduced later. but for 
    now simplicity is king. 
    """
    @Slot()
    def getNext(self):
        if 0<= self.current < len(self.playlist):
            self.current += 1

        episode = self.playlist[self.current]
        #self.settings.addViewHistory(episode)

        try:
            episode.getStream(self.crunchyroll)
        except Exception as ex:
            self.alert.emit("Error loading video stream - may not have access to this content !")

        self.setSource.emit(episode.stream_data[Quality.ULTRA.value].url)
        self.setHeader.emit(episode.name, episode.episode_num)

    @Slot()
    def getPrev(self):
        if self.current > 0:
            self.current -= 1
        
        episode = self.playlist[self.current]
        #self.settings.addViewHistory(episode)
        try:
            episode.getStream(self.crunchyroll)
        except Exception as ex:
            self.alert.emit("Error loading video stream - may not have access to this content !")

        self.setSource.emit(episode.stream_data[Quality.ULTRA.value].url)
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
    def __init__(self, name, episode_num, media_id, collection_id, playhead=0, duration=0, completed = False):
        self.name = name
        self.episode_num = episode_num
        self.media_id = media_id
        self.collection_id = collection_id
        self.playhead = playhead
        self.completed = completed
        self.stream_data = None
    

    def getStream(self, crunchyroll):
        if self.stream_data is None: 
            self.stream_data = crunchyroll.get_media_stream(self.media_id)

    def setPlayhead(self, playhead):
        self.playhead = playhead

    def setCompleted(self, completed):
        self.completed = completed



