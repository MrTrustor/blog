+++
date = "2019-09-13"
draft = false
title = "Change the billing account of all your GCP projects at once"
tags = ["gcp", "billing"]
+++

If you are using GCP, you may at one point need to change the billing account
associated with all your projects. This "billing account migration" can happen
for a number of reasons, but a common one is the consolidation of
several existing billing accounts under a new one.

Below, you'll find a small script to allow you to do that quickly. This script takes all
the projects linked to one billing account and reassigns them to a new one. It
takes at least two arguments: the ID of the old billing account and the ID of
the new one. You can add project IDs that you want to exclude from this
migration as additional arguments.

To be able to execute this script you must have the following permissions/roles:

* "Billing Account User" (`roles/billing.user`) on the new billing account,
* "Billing Account Viewer" (`roles/billing.viewer`) on the old billing account,
* "Project Billing Manager" (`roles/billing.projectManager`) on the projects
  that are impacted.

<script src="https://gist.github.com/MrTrustor/5a75d0169c2dc7d199f1c568b6755124.js"></script>