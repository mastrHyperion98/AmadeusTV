from operator import truediv
import shelve
import os
import time
import requests
import json

class ApplicationSettings():
    def __init__(self):
        self.init_store()
        self.load_cloud()
        self.is_modified = False

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
            store['updated'] = time.time()
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
        self.is_modified = True
    
    def is_completed(self, collection_id, media_id):
        completed = self.store['completion']
        if collection_id in completed and media_id in completed[collection_id]:
            return True
        
        return False

    def add_view_history(self, episode): 
        is_added = False
        history = self.store['watch_history']
        if len(history) > 0: 
            if history[0]['media'] != episode.media_id:
                history.insert(0, episode.toJSON())
                self.store['watch_history'] = history
                is_added = True
        else:
            history.insert(0, episode.toJSON())
            self.store['watch_history'] = history
            is_added = True
        
        if is_added:
            self.is_modified = True

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
        self.is_modified = True

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
        self.is_modified = True

    def is_in_queue(self, series_id):
        return series_id in self.store['queue_index']

    def load_cloud(self):
        if self.store['user_id'] is not None:
            url = "https://1kd8ybmavl.execute-api.us-east-1.amazonaws.com/amadeus-tv-completion-get"
            session = requests.Session()

            user_id=str(self.store['user_id'])

            data = {
                'user_id': user_id,
                'updated': self.store['updated']
            }

            req = session.get(url, json=data)
            content = req.json()
            
            if req.status_code == 200:
                # Update
                self.store['completion'] =content['completion']
                self.store['watch_history'] = content['watch_history']
                self.store['queue'] = content['queue']
                self.store['queue_index'] = content['queue_index']
                self.store['updated'] = content['updated']
                self.store.sync()


            session.close()

    def log_cloud(self):
        if not self.is_modified:
            return 

        url = "https://1kd8ybmavl.execute-api.us-east-1.amazonaws.com/"
        user_id=str(self.store['user_id'])
        updated = time.time()

        data = {
            'user_id': user_id,
            'data': {
                'completion': self.store['completion'],
                'watch_history': self.store['watch_history'],
                'queue': self.store['queue'],
                'queue_index': self.store['queue_index'],
                'updated': updated

            }
        }


        req = requests.put(url, json=data)


        if req.status_code == 200:
            self.store['updated'] = updated
        


        

