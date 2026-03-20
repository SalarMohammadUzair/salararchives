---
title: How to get index of all vidoes of a youtube channel
draft: false
tags:
  - code
---
 You run this command in any directory:
 `yt-dlp --flat-playlist --print webpage_url "https://www.youtube.com/@ChannelName/videos" -o "%(id)s" > urls.txt`
 fetches all links.
 or, if you want titles too:
 `yt-dlp --flat-playlist --print "%(webpage_url)s\t%(title)s" "https://www.youtube.com/@ChannelName/videos" > index.tsv`
 
