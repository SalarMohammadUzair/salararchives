---
publish: true
title: How to get index of all vidoes of a youtube channel
created: 2026-03-20T06:43:54.414+05:00
modified: 2026-03-20T06:49:15.180+05:00
tags:
  - code
---

You run this command in any directory:
`yt-dlp --flat-playlist --print webpage_url "https://www.youtube.com/@ChannelName/videos" -o "%(id)s" > urls.txt`
fetches all links.
or, if you want titles too:
`yt-dlp --flat-playlist --print "%(webpage_url)s\t%(title)s" "https://www.youtube.com/@ChannelName/videos" > index.tsv`
