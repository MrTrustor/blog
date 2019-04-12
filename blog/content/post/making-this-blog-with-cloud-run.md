+++
date = "2019-04-11"
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
didn't seem very "corporate" :-) So, I had updated my setup like this:

* Still using Hugo.
* The website was hosted on [Google Cloud Storage](https://cloud.google.com/storage/docs/) (GCS),
  behind a [Cloud Load Balancer](https://cloud.google.com/load-balancing/docs/).
* I was using [Cloud Build](https://cloud.google.com/cloud-build/docs/) to
  generate and deploy my website. A Git push on my [repository](https://github.com/MrTrustor/blog)
  triggers a build of the website, which was then automatically published on GCS.

## The future

But it's now time for a new update! This blog is now hosted on [Cloud Run](https://cloud.google.com/run/docs/).
Cloud Run is a new serverless hosting service from Google Cloud Platform (GCP).
It's basically a hosted version of [Knative](https://cloud.google.com/knative/),
an open-source, serverless platform built on top of [Istio](https://istio.io)
and [Kubernetes](https://kubernetes.io).

Cloud Run is a fairly simple product to use: you give it a Docker image, set
limits on CPU and Memory usage, and Cloud Run takes care of running, exposing,
and scaling your service.

Let's go over the setup in details.

## Generating the content

This has not really changed. I'm still using my [mrtrustor/hugo](https://hub.docker.com/r/mrtrustor/hugo)
Docker image. I have not been closely following Hugo releases, so it's probably
out of date. But it works for me and, because I'm generating a static website, it
doesn't really have any security consequences.

I'm also using the [Academic theme](https://themes.gohugo.io/academic/) of Hugo,
so I need to pull this before building the content. I'm using it as a git submodule.

Here is the section of the `cloudbuild.yaml` file that relates to building the
content.

```yaml
steps:
- id: 'Download academic theme'
  name: 'gcr.io/cloud-builders/git'
  args: ['submodule', 'update', '--init', '--recursive']
- id: 'Run Hugo'
  name: 'mrtrustor/hugo:0.46'
  args: ['--baseURL=https://blog.mrtrustor.net']
```

At the end of those two steps, I have my website generated in the
`/workspace/blog/public` directory of the Cloud Build worker.

## Building the Docker image

When you use Cloud Run, one important thing to look at is the
[container runtime contract](https://cloud.google.com/run/docs/reference/container-contract).
It's fairly simple, but there is one important thing: your container will be started
with a `$PORT` environment variable, and your application *must* listen on that
port.

To serve my static site, I've chosen to use Nginx because why would I bother
with anything else? I'm building my Docker image on top of the official
Nginx Docker image. This is my Dockerfile:

```
FROM nginx:1.15

ENV PORT=8080 \
    ROBOTS_FILE=robots-prod.txt
ADD site.template /etc/nginx/site.template
ADD blog/public /usr/share/nginx/html/

ENTRYPOINT [ "/bin/bash", "-c", "envsubst '$PORT $HOST $ROBOTS_FILE' < /etc/nginx/site.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'" ]
```

At this point, the website is already generated, so I'm just copying the files
inside the image. Perhaps the most interesting thing here is the use of
`envsubst` to generate a valid Nginx configuration file at when the container is
started. `envsubst` is a small "templating" tool that replaces environment
variables in a file by their values.

Here is my Nginx configuration template:

```
server {
    listen       ${PORT};

    error_page 404 /404.html;

    if ( $http_x_forwarded_proto = "http" ) {
       return 301 https://${HOST}$request_uri;
    }

    location / {
        root   /usr/share/nginx/html;
        index  index.html;
    }

    location /robots.txt {
        alias /usr/share/nginx/html/${ROBOTS_FILE};
    }
}
```

I use 3 environment variables:

* `$PORT` as instructed by the Cloud Run documentation,
* `$HOST` to be able to properly redirect users from HTTP to HTTPS,
* `$ROBOTS_FILE` to switch the `robots.txt` file between the staging and
  production versions of my blog.

Building and pushing the Docker image is fairly straightforward. Here is my
`cloudbuild.yaml` file that does just that:

```yaml
steps:
- id: 'Download academic theme'
  name: 'gcr.io/cloud-builders/git'
  args: ['submodule', 'update', '--init', '--recursive']
- id: 'Run Hugo'
  name: 'mrtrustor/hugo:0.46'
  args: ['--baseURL=https://blog.mrtrustor.net']
  dir: 'blog'
- id: 'Build Image'
  name: 'gcr.io/cloud-builders/docker'
  args: ["build", "-t", "gcr.io/${PROJECT_ID}/blog:${SHORT_SHA}", "."]
- id: 'Push Image'
  name: 'gcr.io/cloud-builders/docker'
  args: ["push", "gcr.io/${PROJECT_ID}/blog:${SHORT_SHA}"]
```

## Deploying the Docker image on Cloud Run

To be able to deploy to Cloud Run from Cloud Build, you need to give a few
additional permissions to the Cloud Build service account. The Cloud Build
service account is `[YOUR_PROJECT_NUMBER]@cloudbuild.gserviceaccount.com`.

* In the [IAM settings page](https://console.cloud.google.com/iam-admin/iam),
  you need to give this service account the **Cloud Run Admin** role.
* In the [service accounts page](https://console.cloud.google.com/iam-admin/serviceaccounts),
  you need to give the Cloud Build service account the **Service Account User**
  role on the *Compute Engine default service account*. This allows Cloud Build
  to *act as* Compute Engine.

Once this is done, you can just deploy to Cloud Run from Cloud Build. Here is
my complete `cloudbuild.yaml` file that does that.

```yaml
steps:
- id: 'Download academic theme'
  name: 'gcr.io/cloud-builders/git'
  args: ['submodule', 'update', '--init', '--recursive']
- id: 'Run Hugo'
  name: 'mrtrustor/hugo:0.46'
  args: ['--baseURL=https://blog.mrtrustor.net']
  dir: 'blog'
- id: 'Build Image'
  name: 'gcr.io/cloud-builders/docker'
  args: ["build", "-t", "gcr.io/${PROJECT_ID}/blog:${SHORT_SHA}", "."]
- id: 'Push Image'
  name: 'gcr.io/cloud-builders/docker'
  args: ["push", "gcr.io/${PROJECT_ID}/blog:${SHORT_SHA}"]
- id: 'Deploy to Cloud Run'
  name: 'gcr.io/cloud-builders/gcloud'
  args: ['beta', 'run', 'deploy', 'blog', '--set-env-vars=HOST=blog.mrtrustor.net,ROBOTS_FILE=robots-prod.txt', '--image', 'gcr.io/${PROJECT_ID}/blog:${SHORT_SHA}', '--allow-unauthenticated', '--region', 'us-central1']
images:
- "gcr.io/${PROJECT_ID}/blog:${SHORT_SHA}"
```

A couple interesting options to look at in the `gcloud beta run deploy` command:

* `--set-env-vars` allows to define runtime environment variables. This is where
  I define my `$HOST` and `$ROBOTS_FILE` variables.
* `--allow-unauthenticated` means that the website is publicy available.

## The last few details

To automatically update my website when I push modifications to my Git
repository, I've set up a [Cloud Build Trigger](https://cloud.google.com/cloud-build/docs/running-builds/automate-builds). This means that as soon as I
push to my *master* branch, my website is generated and deployed. The whole
thing takes less than a minute.

And finally, to use my own domain (`blog.mrtrustor.net`), I configure a
[domain mapping](https://cloud.google.com/run/docs/mapping-custom-domains) in
Cloud Run. This lets know Cloud Run what actual domain you want to use, and it
will take care of generating an SSL certificate for you. You just need to create
the `A` and `AAAA` records it gives you.

## Bonus: Cloud Run vs Cloud Run on GKE

There are actually two versions of Cloud Run. Cloud Run (the one used here) and
Cloud Run on GKE. The first one runs directly on Google's internal infra, when
the second is a Knative deployment on GKE. They both share the same API. The
difference is well explained by Ahmet in this tweet:

<blockquote class="twitter-tweet" data-lang="fr"><p lang="en" dir="ltr">Clearing up some naming confusion &quot;Cloud Run&quot; vs &quot;Cloud Run on GKE&quot;.<br><br>Cloud Run: runs on Google’s internal infra (no VMs)<br>Cloud Run on GKE: Knative installed to your GKE cluster by Google.<br><br>✅ Same API (Knative)<br>✅ Same CLI/UI to deploy<br>✅ Same deployment format (container image) <a href="https://t.co/cXK8HyBoeI">pic.twitter.com/cXK8HyBoeI</a></p>&mdash; ahmet alp balkan (@ahmetb) <a href="https://twitter.com/ahmetb/status/1116041166359654400?ref_src=twsrc%5Etfw">10 avril 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


## References

* [Cloud Run documentation](https://cloud.google.com/run/docs/)
* [Continuous Deployment from git](https://cloud.google.com/run/docs/continuous-deployment)
* [Mapping custom domains](https://cloud.google.com/run/docs/mapping-custom-domains)
* [Container runtime contract](https://cloud.google.com/run/docs/reference/container-contract)