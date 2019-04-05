+++
date = "2019-04-12"
draft = false
title = "Making this blog with Cloud Run"
tags = ["knative","cloud-run","serverless","docker","hugo"]
[header]
image = "making-this-blog-with-cloud-run/header.png"
+++

## Until now
In my first [post](/post/making-this-blog/) on this blog explained how I created
this blog. At the time, I was using:
* [Hugo](https://gohugo.io/) as a static site
generator, that is a tool that turns Markdown into a pretty static website.
* AWS S3 to host the website itself.
* Docker to run Hugo and generate the website from my Markdown files.

Since then, I joined Google and using Amazon's services to host my personal blog
didn't seem very "corporate" :-) So, I updated my setup like this:
* I'm still using Hugo.
* The website has been hosted on [Google Cloud Storage](https://cloud.google.com/storage/docs/) (GCS),
  behind a [Cloud Load Balancer](https://cloud.google.com/load-balancing/docs/).
* I have been using [Cloud Build](https://cloud.google.com/cloud-build/docs/) to
  generate and deploy my website. A Git push on my [repository](https://github.com/MrTrustor/blog)
  triggers a build of the website, which is then automatically published on GCS.

## The future
But it's now time for a new update! This blog is now hosted on [Cloud Run](https://cloud.google.com/run/docs/).
Cloud Run is a new serverless hosting service from Google Cloud Platform (GCP).
It's basically a hosted version of [Knative](https://cloud.google.com/knative/),
an open-source, serverless platform built on top of [Istio](https://istio.io)
and [Kubernetes](https://kubernetes.io).

Cloud Run is a fairly simple product to use: you give it a Docker image, set
limits on CPU and Memory usage, and Cloud Run takes care of running, exposing,
and scaling your service.