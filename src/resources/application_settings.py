from operator import truediv
import shelve
import os

class ApplicationSettings():
    def __init__(self):
        self.init_store()

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
            store['queue'] = []
            store['queue_index'] = {}
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

    def getPassword(self):
        return self.store['password'] 

    def getEmail(self):
        return self.store['email']

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
    def add_view_history(self, episode): 
        is_added = False
        history = self.store['watch_history']
        if len(history) > 0: 
            if history[0].collection_id != episode.collection_id and history[0].media_id != episode.media_id:
                history.insert(0, episode)
                self.store['watch_history'] = history
                is_added = True
        else:
            history.insert(0, episode)
            self.store['watch_history'] = history
            is_added = True

        return is_added

        
    def get_view_history(self, limit, offset=0):
        return self.store['watch_history'][offset:limit+offset]

    def add_queue(self, series):
        series_id = series['series_id']

        if series_id in self.store['queue_index']:
            return

        index = self.store['queue_index']
        index[series_id] = {'queued': True}
        self.store['queue_index'] = index
        queue = self.store['queue']
        queue.append(series)
        self.store['queue'] = queue

    def get_queue(self, limit, offset=0):
        return self.store['queue'][offset:limit+offset]

    def remove_queue(self, series):
        series_id = series['series_id']

        index = self.store['queue_index']
        index.pop(series_id, None)
        self.store['queue_index'] = index
        queue = self.store['queue']
        for s in queue:
            if s['series_id'] == series_id:
                queue.remove(s)
        
        self.store['queue'] = queue

    def is_in_queue(self, series_id):
        return series_id in self.store['queue_index']


        

