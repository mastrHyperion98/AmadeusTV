from operator import truediv
import shelve
import os

class ApplicationSettings():
    def __init__(self):
        self.init_store()
        self.completion = {}
        self.view_history = []

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
            store['completion'] = {}
            store['watch_history'] = []
            store['favorites'] = []
            store['queue'] = [] 
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

    def add_completed(self, collection_id, media_id):
        completed = self.store['completion']
        if collection_id not in completed:
            completed[collection_id] =[media_id]
        elif media_id not in completed:
            completed[collection_id].append(media_id)

        self.store['completion'] = completed

    def is_completed(self, collection_id, media_id):
        completed = self.store['completion']
        if collection_id in completed and media_id in completed[collection_id]:
            return True
        
        return False

    #To-DO Potential add thumbnails to save time
    def add_view_history(self, collection_id, media_id): 
        history = self.store['watch_history']
        history.insert(0, {'collection_id': collection_id, 'media_id': media_id})
        self.store['watch_history'] = history

    def get_view_history(self, limit, offset=0):
        return self.store['watch_history'][offset:limit+offset]

    def add_favorites(self, series_id):
        favorites = self.store['favorites']
        favorites.append(series_id)
        self.store['favorites'] = favorites


    def get_view_favorites(self, limit, offset=0):
        return self.store['favorites'][offset:limit+offset]


    def add_queue(self, series_id):
        queue = self.store['queue']
        queue.append(series_id)
        self.store['queue'] = queue

    def get_view_queue(self, limit, offset=0):
        return self.store['queue'][offset:limit+offset]


        

