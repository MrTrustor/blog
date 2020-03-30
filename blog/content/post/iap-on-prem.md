+++
date = "2020-03-09"
draft = false
title = "Identity-Aware Proxy for On-Prem applications"
tags = ["iap"]
+++

I have a couple internal systems that I run at home, and that I want to be able to access from outside.
I want only my partner and myself to be able to access those systems, and I want that access to be as
transparent as possible for her. For that, I decided to use Google's
[Identity-Aware Proxy](https://cloud.google.com/iap) (IAP)!

IAP is a Google Cloud feature that allows you to implement
Google's [BeyondCorp](https://cloud.google.com/beyondcorp) security model. The goal of BeyondCorp (and of IAP) is
to get rid of corporate VPNs: the bane of the existence of office workers all around the world. In this model,
corporate applications are accessed through a proxy that deals with authenticating and authorizing the user.
That proxy is available directly on the Internet, removing the need for a VPN. When accessing an application
behind IAP, the user is authenticated, authorized, and the connection is encrypted (with SSL).

In Google Cloud, IAP is a feature that you enable on an HTTPS Load Balancer. Until now, Google Cloud Load Balancers
were only compatible with Google Cloud-hosted resources (virtual machines, Cloud Storage buckets, etc.). That meant
that the only way to benefit from IAP for applications hosted on-prem was to setup another reverse proxy within
Google Cloud. That's how the [IAP connector](https://cloud.google.com/iap/docs/enabling-on-prem-howto) does it,
using [Ambassador](https://www.envoyproxy.io/docs/envoy/latest/start/distro/ambassador).

![iap-connector](/img/iap-on-prem/iap-connector.png)

_Note: You don't have to configure a VPN between your VPC and On-Prem, you can route the traffic from your reverse
proxy to On-Prem over the public Internet._

The problem with that architecture is that it's really not optimized: you need to setup a whole VPC, at least a VM
(or even a managed instance group, or a Kubernetes cluster, if you want HA), and optionnally a VPN.

Fortunately, Google Cloud recently released a feature that went a bit under the radar:
[Internet network endpoint groups](https://cloud.google.com/load-balancing/docs/negs/internet-neg-concepts) (Internet NEGs).
This allows Google Load Balancers to have backends outside of Google Cloud! And, best of all, that backend can
be a hostname, not only a static IP! That is really convenient for me, since my ISP doesn't attribute static IPs.
You can now simplify greatly the setup:

![iap-neg](/img/iap-on-prem/iap-neg.png)

_Note: If you want the traffic between the load balancer and your application to be encrypted, then
your application has to listen on HTTPS, and you need to use that as a backend for the load balancer._

Here is how I did it, details will vary for you, of course.

1. Configure your router to forward incomming traffic on your application's port to the application.
  * If you can, restrict that forwarding to `34.96.0.0/20` and `34.127.192.0/18` ([source](https://cloud.google.com/load-balancing/docs/https/troubleshooting-ext-https-lbs#traffic_does_not_reach_the_endpoints)). Check the `_cloud-eoips.googleusercontent.com` DNS TXT record for the current list of IP ranges.
  * If that's not possible on your router, then setup a firewall rule to restrict incomming traffic to those ranges.
2. If your ISP gives you a dynamic IP (like me), then setup some kind of dynamic DNS to get a stable hostname.
3. Reserve a [static IP address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address)
   on GCP.
4. Point a DNS record that you want to use for your application (`myapp.example.com` for example) to
   the newly reserved static IP.
5. Create an Internet NEG that targets your home IP or home hostname, and the application port, following the
   [documentation](https://cloud.google.com/load-balancing/docs/negs/setting-up-internet-negs).
6. Create an HTTP(S) Load Balancer:
   * Use the newly created Internet NEG as backend service.
   * Create at least two frontends: one for HTTP and one for HTTPS. Use the static IP you reserved earlier.
   * Create a Google-managed SSL certificate with the hostname `myapp.example.com`.

After a few minutes, the load balancer will have initialized, and you should be able to access your application
through `myapp.example.com`, without any authentication nor authorization. You can now enable IAP following
the [documentation](https://cloud.google.com/iap/docs/enabling-compute-howto) on your new load balancer.
Grant the _IAP-Secured Web App User_ IAM role to anyone who needs to access the application.

Here you go! An On-Prem application, protected Google-style with Identity-Aware Proxy!