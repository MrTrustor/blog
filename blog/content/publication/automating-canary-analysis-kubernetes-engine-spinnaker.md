+++
title = "Automating Canary Analysis on Google Kubernetes Engine with Spinnaker"
date = 2018-09-10T00:00:00
draft = false

authors = ["Théo Chamley"]

publication = "Google Cloud website"

abstract = "Spinnaker is an open source, continuous delivery system led by Netflix and Google to manage the deployment of apps on different computing platforms, including App Engine, GKE, Compute Engine, AWS, and Azure. Using Spinnaker, you can implement advanced deployment methods, including canary deployments. In a canary deployment, you expose a new version of your app to a small portion of your production traffic and analyze its behavior before going ahead with the full deployment. This lets you mitigate risks before deploying a new version to all of your users. To use canary deployments, you must accurately compare the behavior of the old and new versions of your app. The differences can be subtle and might take some time to appear. You might also have a lot of different metrics to examine. To solve those problems, Spinnaker has an automated canary analysis feature: it reads the metrics of both versions from your monitoring system and runs a statistical analysis to automate the comparison. This tutorial shows you how to do an automated canary analysis on an app deployed on GKE and also monitored by Stackdriver. Spinnaker is an advanced app deployment and management platform for organizations with complex deployment scenarios, often with a dedicated release engineering function. You can run this tutorial without prior Spinnaker experience. However, implementing automated canary analysis in production is generally done by teams that already have Spinnaker experience, a strong monitoring system, and that know how to determine if a release is safe."

url_custom = [
  {name = "Solution", url = "https://cloud.google.com/solutions/automated-canary-analysis-kubernetes-engine-spinnaker"}
  ]

+++
