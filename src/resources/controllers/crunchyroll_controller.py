import json
from pickle import NONE
from PySide2.QtCore import QObject, Slot, Signal
from datetime import datetime as dt
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


def current_season_tag():
    currentMonth = dt.now().month
    currentYear = dt.now().year
    season = ''
    if currentMonth < 4:
        season = 'winter'
    elif currentMonth < 7:
        season = 'spring'
    elif currentMonth < 10:
        season = 'summer'
    else:
        season = 'fall'

    
    season_tag = f'season:{season}_{currentYear}'
    return season_tag

class CrunchyrollController(QObject):
    def __init__(self, limit=10):
        QObject.__init__(self)


        self.crunchyroll = CrunchyrollServer()
        self.settings = ApplicationSettings()

        if self.settings.isLogin() or self.settings.getRememberMe():
            self.crunchyroll.login(self.settings.getEmail(), self.settings.getPassword())
        else:
            self.crunchyroll.create_session()

        self.limit = limit

        self.playlist = []
        self.current = 0

    #Signals
    setSource = Signal(str)
    setHeader = Signal(str, str)
    setQuality = Signal(str)
    addSimulcast = Signal(str, str)
    addUpdated = Signal(str, str)
    addWatchHistory = Signal(str)
    addWatchHistoryDynamic = Signal(str)
    addQueue = Signal(str)
    removeQueue=Signal(str)
    setQueueState = Signal(str)
    addSearch = Signal(str, str)
    startup = Signal(str)
    login = Signal(bool)
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

    @Slot()
    def getSimulcast(self):
        simulcast = self.crunchyroll.filter_series(limit=self.limit, offset=0, filter_type = Filters.SIMULCAST, filter_tag=current_season_tag())

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
    def getWatchHistory(self):
        history = self.settings.get_view_history(limit=self.limit)
        json_episodes = []
        for episode in history:
            json_episodes.append(episode)

        json_episodes = json.dumps(json_episodes)
        self.addWatchHistory.emit(json_episodes)


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
    def addToQueue(self, data):
        self.settings.add_queue(json.loads(data))
        self.addQueue.emit(data)

    @Slot(str)
    def removeFromQueue(self, data):
        json_data = json.loads(data)
        self.settings.remove_queue(json_data)
        self.removeQueue.emit(json_data['series_id'])
    
    @Slot(str)
    def getQueueState(self, series_id):
        state = self.settings.is_in_queue(series_id)

        if state:
            self.setQueueState.emit("IN_QUEUE")
        else:
            self.setQueueState.emit("NOT_IN_QUEUE")

    @Slot()
    def getQueue(self):
        queue = self.settings.get_queue(limit=self.limit)
        for series in queue:
            data = json.dumps(series)
            self.addQueue.emit(data)


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
    def explore(self, q):
        simulcast = self.crunchyroll.filter_series(limit=1000, offset=0, filter_type = Filters.TAG, filter_tag=q.lower())
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

    
        self.fetchEpisodeList(default.name, default.collection_id)

    @Slot(str, str)
    def fetchEpisodeList(self, collection_name, collection_id):
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
            collection_name: episode.collection_name
            episode_number = episode.episode_number
            collection_id = collection_id
            series_id = episode.series_id
            thumbnail = episode.screenshot_image['full_url']
            media_id = episode.media_id

            isWatched = self.settings.is_completed(collection_id, media_id)

            json_def = {
                "collection_name": collection_name,
                "name": name,
                "episode_number": episode_number,
                "collection_id": collection_id,
                "series_id": series_id,
                "thumbnail": thumbnail,
                "media_id": media_id,
                "isWatched": isWatched
            }
            json_episodes.append(json_def)
            self.addMediaToPlaylist(collection_name, media_id, name, episode_number, collection_id, thumbnail)

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
        episode = self.playlist[self.current]
        if episode.completed:
            self.settings.add_completed(episode.collection_id,episode.media_id)

        else:
            is_added = self.settings.add_view_history(episode)
            if is_added:
                self.emit_episode(episode)


    @Slot(str, str, str, str, str)
    def addMediaToPlaylist(self, collection_name, media_id, name, episode_num, collection_id, img):
        self.playlist.append(Episode(collection_name, name, episode_num, media_id, collection_id, img))

    @Slot(str)
    def setPlaylistByID(self, id):
        for index in range(len(self.playlist)):
            episode = self.playlist[index]
            if episode.media_id.strip() == id.strip():
                self.current = index


    @Slot(int)
    def setPlaylistIndex(self, index):
        if index >= 0 and index < len(self.playlist):
            self.current = index


    @Slot()
    def getCurrent(self):
        if self.current < len(self.playlist):
            episode = self.playlist[self.current]
        else: 
            episode = self.playlist[len(self.playlist)-1]
        #self.settings.addViewHistory(episode)
        try:
            episode.getStream(self.crunchyroll)
        except Exception as ex:
            self.alert.emit("Error loading video stream - may not have access to this content !")

        self.setSource.emit(episode.stream[Quality.HIGH.value].url)
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

        self.setSource.emit(episode.stream[Quality.HIGH.value].url)
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

        self.setSource.emit(episode.stream[Quality.HIGH.value].url)
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
    
        
    def emit_episode(self, episode):
        json_episodes = []
        name = episode.name
        episode_number = episode.episode_num
        collection_id = episode.collection_id
        thumbnail = episode.thumbnail
        media_id = episode.media_id
        collection_name = episode.collection_name

        json_def = {
            "name": name,
            "collection_name": collection_name,
            "episode_num": episode_number,
            "collection_id": collection_id,
            "thumbnail": thumbnail,
            "media_id": media_id,
        }
        json_episodes.append(json_def)

        json_episodes = json.dumps(json_episodes)
        self.addWatchHistoryDynamic.emit(json_episodes)

    def updateHistory(self, current):
        self.settings.addViewHistory(current.media_id)

    def close(self):
        self.crunchyroll.close()
        self.settings.log_cloud()

    

class Episode():
    def __init__(self, collection_name, name, episode_num, media_id, collection_id, thumbnail, playhead=0, duration=0, completed = False):
        self.collection_name = collection_name
        self.name = name
        self.episode_num = episode_num
        self.media_id = media_id
        self.collection_id = collection_id
        self.playhead = playhead
        self.completed = completed
        self.thumbnail = thumbnail
        self.stream = None
    

    def getStream(self, crunchyroll):
        if self.stream is None: 
            self.stream = crunchyroll.get_media_stream(self.media_id)

    def setPlayhead(self, playhead):
        self.playhead = playhead

    def setCompleted(self, completed):
        self.completed = completed

    def toJSON(self):
        return {
            'collection_name': self.collection_name,
            'name': self.name,
            'episode_num': self.episode_num,
            'media': self.media_id,
            'collection_id': self.collection_id,
            'playhead': self.playhead,
            'completed': self.completed,
            'thumbnail': self.thumbnail,
        }



