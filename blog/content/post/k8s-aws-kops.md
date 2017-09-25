+++
date = "2016-10-23"
draft = false
title = "Kubernetes on AWS - Kops"
tags = ["aws","k8s","kubernetes", "high-avaibility", "kops"]
[header]
image = "k8s-aws-kops/aws-network-banner.png"
+++

## Introduction

[Kubernetes](https://kubernetes.io) is the leading container orchestration solution. It promises to standardize the way you run applications, without worrying if you are running on bare-metal, on a public cloud provider or on a private cloud.

AWS being the leading public cloud solution, it is important to be able to run Kubernetes easily on this provider.
In this post, I will show you how to create a production-ready Kubernetes cluster on AWS from scratch. In a future post, I will explain how to run a fairly complex application -Gitlab- with complete high availability on this cluster.

This post assumes some knowledge of both AWS and Kubernetes. You should be familiar with the following elements.

In AWS:

* The AWS CLI,
* The [basics of networking in AWS](/post/aws-networking/),
* AWS Route53 Hosted Zones,
* S3 buckets,

For Kubernetes:

* What Kubernetes is (*obviously*),
* ``kubectl``,
* The basic architecture of Kubernetes.

## Kops

So far, running Kubernetes (K8s) on AWS has always been challenging and quite long if you wanted a production cluster. The ``kube-up.sh`` script, while quickly creating a cluster, is nowhere near sufficient for production: no auto-scaling group, no VPC management, etc.

This is changing, mainly thanks to [Kops](https://github.com/kubernetes/kops). Kops is a tool under active development by the K8s AWS special interest group. Written in Go, its goal is to manage K8s clusters. You can now provision and customize far better installations:

* Auto-scaling for the workers (for self-healing),
* Possible HA for the master(s),
* Customization of the VPC and subnets used,
* Inter-pod networking is done via native AWS routing by default,
* Possibility to export a corresponding [Terraform](https://www.terraform.io) stack.

## Creating a simple cluster with Kops

For the purpose of this article, I will create a simple cluster: one master, 3 nodes in 3 availability zones.
Here is how to do it with Kops.
You need:

* To have a profile declared in ``~/.aws/credentials``,
* To create a S3 bucket to store Kops state,
* To have a Route53 Hosted Zone in the same AWS account (Kops will use it to create records needed by the cluster).

You can then declare your cluster:

```bash
export AWS_PROFILE=my-profile
export KOPS_STATE_STORE=s3://my-kops-bucket
kops create cluster --cloud=aws \
  --dns-zone=k8s.myzone.net --master-size=t2.medium \
  --master-zones=eu-west-1a \
  --network-cidr=10.0.0.0/22 --node-count=3 \
  --node-size=m4.large \
  --zones=eu-west-1a,eu-west-1b,eu-west-1c \
  --name=k8s.myzone.net
```

At this stage, only the cluster's description is created, not the cluster itself. You can still change any option by editing your cluster:

```bash
kops edit cluster k8s.myzone.net
```

And when you are satisfied, you can actually create the cluster:

```bash
kops update cluster k8s.myzone.net --yes
```

After a few minutes, your ``kubectl`` should be able to connect to the newly created cluster:

```bash
kubectl get nodes
NAME                                           STATUS    AGE
ip-10-0-0-159.eu-west-1.compute.internal       Ready     1d
ip-10-0-0-213.eu-west-1.compute.internal       Ready     1d
ip-10-0-1-105.eu-west-1.compute.internal       Ready     1d
ip-10-0-1-208.eu-west-1.compute.internal       Ready     1d
```

## Upgrading a cluster

Kops also allows to easily upgrade a running Kubernetes cluster with no downtime, provided you have a multi-master setup. Just edit the cluster and change the ``kubernetesVersion``:

```bash
kops edit cluster k8s.myzone.net
```

When you apply the update, Kops will automatically do a rolling-upgrade of the cluster:

```bash
kops update cluster k8s.myzone.net --yes
kops rolling-update cluster k8s.myzone.net --yes
```

## Conclusion

Kops allows to create and easily manage Kubernetes clusters on AWS, with real production in mind. This solution is far easier and better than anything I have seen to provision K8s on AWS. It also allows a wide range of customizations.

In the next post, I will show how to leverage AWS managed services in conjunction with Kubernetes to run applications (with their databases and data) in a truly highly available fashion.
