+++
title = "Safe rollouts with Anthos Config Management"
date = 2020-07-28T00:00:00
draft = false

authors = ["Théo Chamley"]

publication = "Google Cloud website"

abstract = "This document shows cluster operators and platform administrators how to safely roll out changes across multiple environments by using Anthos Config Management. Anthos Config Management can help you avoid errors that affect all of your environments simultaneously. Anthos Config Management lets you manage single clusters, multi-tenant clusters, and multi-cluster Kubernetes configurations by using files stored in a Git repository. Anthos Config Management combines three technologies—Config Sync, Policy Controller, and Config Connector. Config Sync watches for updates to all files in the Git repository and applies changes to all relevant clusters automatically. Policy Controller manages and enforces policies for objects in your clusters. Config Connector uses Google Kubernetes Engine (GKE) custom resources to manage cloud resources."

url_custom = [
  {name = "Reference guide", url = "https://cloud.google.com/solutions/safe-rollouts-with-anthos-config-management"}
  ]

+++
