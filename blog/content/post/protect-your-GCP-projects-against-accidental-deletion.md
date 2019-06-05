+++
date = "2019-06-05"
draft = false
title = "Protect your GCP projects against accidental deletion"
tags = ["gcp", "security"]
+++

Google Cloud Platform (GCP) uses a specific resource hierarchy. At the very top,
you have an organisation, tied to a domain (for example: mrtrustor.net). Inside
that organisation, you can have folders and subfolders. Finally, you have
projects, which can be inside folders, or directly under the organisation node.
Projects are where your cloud resources (VMs, databases, etc.) actually live.
By default, projects are completely isolated from one another, especially on
at a network level.

A typical pattern is to use a project for every application/environment pair. In
a large organisation, you can easily end up with many projects. Read
[Best practices for enterprise organizations](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations)
for more information.

## The problem

While projects are very convenient, deleting them is also fairly easy. Provided
you have the right IAM roles, you can delete a project with a single command:
`gcloud projects delete PROJECT_ID`. Doing this through the GCP Console is
also quite easy: a few clicks, a project ID to copy/paste, and your project is
shut down.

![GCP console project delete](../../img/protect-your-GCP-projects-against-accidental-deletion/console-delete.png)

To be fair, in either case, projects are not deleted immediately, but after a
30-day period. However, resources are shutdown immediately. As you can see, it
can be fairly easy for someone to make a mistake and delete a production project,
especially if you are using an automation tool like Terraform to create projects
in the first place.

## The solution

GCP has a built-in protection against project deletion that's not widely known.
It's called "Liens". By creating a lien on a project, you prevent its deletion.
For example:

```
gcloud alpha resource-manager liens create \
  --restrictions=resourcemanager.projects.delete \
  --reason="Super important production system" \
  --project PROJECT_ID
```

Please, create liens on your production projects :-) This is even more important
if you are using [Shared VPC](https://cloud.google.com/vpc/docs/shared-vpc).

See [Protecting Projects from Accidental Deletion with Liens](https://cloud.google.com/resource-manager/docs/project-liens)
for the whole documentation. There is also a [Terraform resource](https://www.terraform.io/docs/providers/google/r/resource_manager_lien.html) to create liens.