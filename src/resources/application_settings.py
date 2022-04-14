from operator import truediv
import shelve
import os
import json

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
            store['watch_history'] = {}
            store['favorites'] = {}
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