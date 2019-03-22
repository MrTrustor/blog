+++
title = "GitOps-style continuous delivery with Cloud Build"
date = 2019-01-31T00:00:00
draft = false

authors = ["Théo Chamley"]

publication = "Google Cloud website"

abstract = "This article explains how to create a continuous integration and delivery (CI/CD) pipeline on Google Cloud Platform using only hosted products and the popular GitOps methodology.
Google engineers have been storing configuration and deployment files in our primary source code repository for a long time. This methodology is described in the book Site Reliability Engineering, Chapter 8 (Beyer et. al., 2016), and was demonstrated by Kelsey Hightower during his Google Cloud Next '17 keynote. The term GitOps itself was coined by Weaveworks. A key part of GitOps is the idea of environments-as-code: describing your deployments declaratively using files (for example, Kubernetes manifests) stored in a Git repository.
In this tutorial, you create a CI/CD pipeline that automatically builds a container image from committed code, stores the image in Container Registry, updates a Kubernetes manifest in a Git repository, and deploys the application to Google Kubernetes Engine using that manifest."

url_custom = [
  {name = "Tutorial", url = "https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build"}
  ]
url_code = "https://github.com/GoogleCloudPlatform/gke-gitops-tutorial-cloudbuild"

+++
