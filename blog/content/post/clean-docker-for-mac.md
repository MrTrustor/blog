+++
date = "2016-09-17"
draft = false
math = false
tags = ["docker", "mac", "os x"]
title = "Cleaning up Docker For Mac"
+++

Docker For Mac has really changed how I work: I now use it for all my linux-related developments. The integration is OS X is really well done and it's really perfect for a development environment.

The only problem is that Docker For Mac uses a file called ``Docker.qcow2`` that takes more and more disk space as time passes (mine got to 20GB). Deleting images or containers does not decrease the size of this file. The issue has been reported several times (like [here](https://forums.docker.com/t/where-does-docker-keep-images-containers-so-i-can-better-track-my-disk-usage/8370/13) for instance), but no official fix exists yet, even with this week's release of Docker 1.12.1.

After discussing with a Docker employee working on Docker For Mac and Docker For Windows in Paris during last [Docker Paris Meetup]({{< relref "post/rancher-handson-part1.md" >}}), it seems that the only solution right now is to simply delete this file. However deleting it will also remove all your containers and images.

Here is a small script that will do that for you, and you can give it some images that you would like to keep as arguments.

<script src="https://gist.github.com/MrTrustor/e690ba75cefe844086f5e7da909b35ce.js"></script>
