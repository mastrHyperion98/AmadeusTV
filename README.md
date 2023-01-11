# About Amadeus TV

Amadeus TV is a linux crunchyroll streaming application being developed in Python with the QT library. With the recent merge of Crunchyroll and Funimation this is a good opportunity to create a single app for Linux that unifies nearly the entire Anime catalog available in North America and Europe. 

The application interfaces with the Crunchyroll semi-public api via a python wrapper that I wrote called crunchyroll-connect. Consequently, this application does not provide "premium" content for free. The user must log in with a valid Crunchyroll account and have an active premium membership to access any paid content. 

<details>
  <summary>Application Screenshots</summary>
  <img src="example_images/Example2.png" name="home_page">
  <img src="example_images/Example3.png" name="series_page">
  <img src="example_images/Example1.png" name="video_player">
</details>

# Features: 

Amadeus TV uses a crunchyroll API wrapper that I wrote, crunchyroll-connect (not yet updated for the new API that was rolled out). It supports the following features.

* Login to Crunchyroll
* Queue and watch history stored on AWS using Crunchyroll ID so no need to create a new account
* Search the entire Crunchyroll Catalog by key words
* Search by Category
* Home page also displays recently updated shows and current Simulcasts. 
* Video playback 
  * pause
  * mute
  * playback speed
  * skipping
  * auto play next episode
  
  
 <strong>A PREMIUM CRUNCHYROLL ACCOUNT IS NEEDED TO ACCESS PREMIUM CONTENT </strong>

# How to contribute

The media player, officially only works with Gstreamer and Linux, any other configurations have not been tested and are not supported. For example, the default media backend that QT uses for Windows does not support the video format that we get from Crunchyroll.

1. Clone the repository (dev branch)
2. Create a virtualvenv environment `virtualvenv path-to-create`
3. Activate environment `source path-name/bin/activate` (This is for Unix may vary on windows `source path-name/bin/activate.bat`)
4. Install required packages `pip install -r requirements.txt'
5. When contributing to a new issue, unless project Admin create new branch based off of dev and PR any changes.
6. All new branches should contain the `feature-` prefix followed by the name of the issue or a abreviation/number
