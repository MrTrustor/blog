+++
date = "2017-05-29"
draft = false
title = "How to use Kubernetes to fix GKE"
tags = ["kubernetes","iptables","gke","gcp","vpn"]
[header]
image = "iptables-kubernetes/header.png"
+++

**Note: Since writing this post, I joined Google. We have released a feature
called [IP Aliases](https://cloud.google.com/kubernetes-engine/docs/how-to/ip-aliases)
that addresses the problem described in this article, and much more. Activating IP Aliases requires creating a new cluster. If you can't do that, then you can now
change the configuration of the `ip-masquerade-agent` as described
[here](https://cloud.google.com/kubernetes-engine/docs/how-to/ip-masquerade-agent#specify-non-masq-cidrs).
This gives the same end-result as the solution described in this article, but
is much cleaner.**

I recently ran into a problem while using Google Container Engine (GKE), the
managed Kubernetes by Google. This lead me to an interesting solution that
can be used for a large range of issues you could encounter in Kubernetes.

## The Problem

I was unsuccessfully trying to have my pods communicate with an application
available through a VPN: everything was working as expected from a VM but the
pods in the GKE cluster had no network connectivity with the services on the
other side of the VPN. Stranger still, when testing directly from the nodes of
the cluster, everything was fine.


## The Diagnostic

The fact that everything was working from the nodes of the cluster, but not
the pods told me that it was probably a NAT problem. Indeed, after digging
around, I discovered that the requests sent by my pods were not NATted to the
IPs of the hosts they were on. This was strange because the pods had no problem
accessing external resources.

This is problematic because the pods' IPs are in a "virtual" network that exists
only in the GCP environment (or only in the Kubernetes cluster if you are using
a SDN provider such as Weave): the applications on the other side of the VPN
do not know those IPs and have no network route to answer.

![schema](/img/iptables-kubernetes/gke-iptables-problem.jpg)

After a bit of _Google-fu_, I found [this GitHub issue](https://github.com/kubernetes/kubernetes/issues/6545)
that matched my problem. As mentioned in this link, Google uses the following
`iptables` configuration to allow pods to communicate with external services:

```
iptables -A POSTROUTING ! -d 10.0.0.0/8 \
  -m comment --comment “kubenet: outbound traffic" -m addrtype \
  ! --dst-type LOCAL -j MASQUERADE -t nat
```

What does this mean? It means that traffic from the pods will be NATted to the
host IP **only if** the destination is **not** in `10.0.0.0/8`.

This `10.0.0.0/8` is the problem: it's too large. It contains both the Google
Cloud network (`10.10.0.0/24`) and the GKE internal network (`10.40.0.0/14`)
but also the network on the other side of the VPN (`10.11.0.0/24`)! Because
my pods were trying to communicate with services whose IPs were in the
`10.11.0.0/24` range, they were not source-NATted.

## The solution

The best solution I found that is not _too_ hacky is to add a single `iptables`
line to the hosts:

```
iptables -A POSTROUTING -d 10.11.0.0/24 \
   -m addrtype ! --dst-type LOCAL -j MASQUERADE -t nat
```

This means that the traffic that goes through the VPN _will_ get NATted.

## Automating the solution

This is the world of Kubernetes: there is no way that I am going to apply this
fix manually on all nodes, especially when using GKE! How can Kubernetes
itself be used to fix this problem? We need to apply a patch on all nodes,
current and future, of the cluster: with these specifications, a `DaemonSet`
seems to be the obvious solution.

If you don't know, a `DaemonSet` is a Kubernetes controller that ensures that
one copy of the given pod runs at all time on all nodes of the cluster. This
is typically used for logging or monitoring.

Using [this example](https://github.com/kubernetes/contrib/tree/master/startup-script)
from the _kubernetes/contrib_ GitHub repository, I was able to write this very
simple `DaemonSet` that fixes my problem permanently (in a way that I find not too
ugly).

```yaml
kind: DaemonSet
apiVersion: extensions/v1beta1
metadata:
  name: fix-nat
  labels:
    app: fix-nat
spec:
  template:
    metadata:
      labels:
        app: fix-nat
    spec:
      hostPID: true
      containers:
        - name: fix-nat
          image: gcr.io/google-containers/startup-script:v1
          imagePullPolicy: Always
          securityContext:
            privileged: true
          env:
          - name: STARTUP_SCRIPT
            value: |
              #! /bin/bash
              while true; do
                iptables-save | grep MASQUERADE | grep -q "NAT-VPN"
                if [ $? -ne 0 ]; then
                  echo "Missing NAT rule for VPN, adding it"
                  iptables -A POSTROUTING -d 10.11.0.0/24 -m comment --comment "NAT-VPN: SNAT for outbound traffic through VPN" -m addrtype ! --dst-type LOCAL -j MASQUERADE -t nat
                fi
                sleep 60
              done
```

This small script will check every minute, forever, if we have the right `iptables`
rule and, if not, add it.

Note that the `privileged: true` is necessary for the pod to be able to change
`iptables` rules from the host.

## Conclusion

I used this method to fix a problem with the NAT configuration of GKE, but it
can easily be used to automate a lot of different things on the nodes of your
Kubernetes cluster. If you have ever played a little with [Kargo](https://github.com/kubernetes-incubator/kargo)
or the [Kops](https://blog.mrtrustor.net/post/k8s-aws-kops/) internals, you will
know that Kubernetes can largely be used to bootstrap itself. Similarly, it
can be used to fix most things in the configuration of the nodes of your cluster.
