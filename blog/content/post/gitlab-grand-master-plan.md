+++
date = "2016-09-14T15:25:14Z"
draft = false
image = "gitlab-grand-master-plan/header.png"
math = false
tags = ["gitlab", "git", "agile", "conversational development"]
title = "Gitlab Grand Master Plan"

+++

On september, the 13th, at 7p.m (CEST), Gitlab presented its "[Grand Master Plan](https://about.gitlab.com/2016/09/14/gitlab-live-event-recap/)": the direction that the company and its product will take in the coming months.

## Reminders

Gitlab is a company that was created to back the product of the same name. Gitlab was conceived as a competitor of Github: a centralized platform for managing Git repositories with a web GUI. Like Github, Gitlab lets you fork a project (create your own copy), and create Pull Requests (called Merge Request - a better name I think), which is a way for you to submit modifications for code review.

Since its beginning, Gitlab evolved a lot functionally and now brings some features that are not available anywhere else (non-comprehensive list):

* GitlabCI: Continuous Integration directly in Gitlab, mainly based on Docker,
* Docker Registry: Docker images hosting,
* Issues board: project-integrated Kanban,
* Graphical Merge Conflict Resolution: when there is a conflict in a merge request, Gitlab now allows you to fix it with a GUI when you previously had to use the terminal for this.

## Economic model

Gitlab is an open-source product, that you can install as much as you want, where you want. [Gitlab.com](https://gitlab.com/users/sign_in) is the SaaS version of Gitlab: completely free, with all the features (CI, private projects, etc.). However, Gitlab.com tends to be a little overloaded (for instance, CI jobs can take a while to start sometimes) and is always on the latest of the versions, bugs included.

Gitlab Enterprise Edition is the paying version of Gitlab on which Gitlab actually earns money. It is close to the Community Edition (the open-source one), but with some more features (using ElasticSearch as a search backend for instance).

## The company

Gitlab had 9 employees 18 months ago. They are now a hundred and finished their series B round with $20 million. Gitlab is a fully remote company: if it is based in Amsterdam all the employees actually live and work all around the world. They communicate via (video-)chats and Gitlab issues.

Gitlab is also a periodic-release project: a new minor version goes live every month (on the 22nd), whatever the features are ready. This methodology allowed them to ship an impressive amount of features in the last 18 months.

# Grand Master Plan

Gitlab's ambition is to provide a tightly integrated family of products to manage the whole lifecycle of a software project - from idea to production - while keeping trace of everything and reducing the development cycles. Gitlab also states their intent to avoid vendor lock-in and, for this reason, opens every API for you to be able to replace each tool they ship by your own.

They call this "Conversational Development", and they want it to be an evolution of the Agile movement.

Pictures speaking louder than words, here is a demo of what they want to do (NB: I would estimate that 80% of the features shown in the video are already implemented):

<iframe width="560" height="315" src="https://www.youtube.com/embed/ZRcWCWatdas" frameborder="0" allowfullscreen></iframe>

The whole webcast is available here:

<iframe width="560" height="315" src="https://www.youtube.com/embed/KrF7jNfDSnI" frameborder="0" allowfullscreen></iframe>

# Conclusion

Github is currently hosting its conference, Github Universe, in which they announced, among other things, something akin to Gitlab's Issues Board (i.e a Kanban), some changes to the review process and a new GraphQL API. While some other announces may be coming during Github's conference, I think that Gitlab already took a part of the market from Github and that this progression is going to continue thanks to the incredible rate at which the product is developped. The existing features and the ones that are coming are going to make Gitlab an even more central tool than it is today. It is probable that, in a few months, we will not need anything more than Gitlab to manage the whole lifecycle of a project.
