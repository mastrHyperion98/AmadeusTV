# About Amadeus TV

Amadeus TV is a linux crunchyroll streaming application being developed in Python with the QT library. With the recent merge of Crunchyroll and Funimation this is a good opportunity to create a single app for Linux that unifies nearly the entire Anime catalog available in North America and Europe. 

The application interfaces with the Crunchyroll semi-public api via a python wrapper that I wrote called crunchyroll-connect. Consequently, this application does not provide "premium" content for free. The user must log in with a valid Crunchyroll account and have an active premium membership to access any paid content. 

# Supported Platforms
* Linux 
* Android (may be possible)

Note: Why only Linux and Android? 

At the moment the video player implements QT/QML provided Media player. On Linux, it uses GStreamer as its back end which is capable of handling the crunchyroll stream data in the format that they are provided. The Windows media engine (DirectShow and MediaFoundation) don't work. More testing will be done and I am looking into using ffmpeg, but this project is being made as a hobby and for personal use. I am running Linux, so I do not want to make this project more complicated than it has to. I am also looking at bundling any potential version of windows with Gstreamer. Not sure how to force QML and QT to use it. 

# How to use: 

Once a release candidate you can simply download it and execute the binary file after giving it executable permissions. 
Flatpak and AppImage are being considered for the first major release of the application. 

# How to contribute

The media player, officially only works with Gstreamer and Linux, any other configurations have not been tested and are not supported. 

1. Clone the repository (dev branch)
2. Create a virtualvenv environment `virtualvenv path-to-create`
3. Activate environment `source path-name/bin/activate` (This is for Unix may vary on windows `source path-name/bin/activate.bat`)
4. Install required packages `pip install -r requirements.txt'
5. When contributing to a new issue, unless project Admin create new branch based off of dev and PR any changes.
