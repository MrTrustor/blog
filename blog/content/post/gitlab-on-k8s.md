+++
date = "2016-11-04"
draft = false
title = "Gitlab on Kubernetes + AWS"
image = "gitlab-on-k8s/gitlab-kubernetes.png"
tags = ["aws","k8s","kubernetes", "high-avaibility", "gitlab"]
+++

## Introduction

In the last [post](/post/k8s-aws-kops/) we saw how to create a production-ready
[Kubernetes](http://kubernetes.io/) (K8s) cluster on AWS with
[Kops](https://github.com/kubernetes/kops). Now, let's see how to use it in
conjunction with AWS managed services to host a highly available application:
[Gitlab](/post/gitlab-grand-master-plan/).

Having some knowledge of Terraform, AWS and Kubernetes will help you in reading
of this post.

All the code used in this post is available on
[Github](https://github.com/MrTrustor/gitlab-kubernetes-aws).

### Gitlab architecture

Gitlab is an open-source competitor of Github. It is composed of several parts:

* A relational database (PostgreSQL is the default),
* A "distributed" filesystem for the Git repositories,
* A Redis server for cache and sessions,
* A "core" app with Unicorn, SSH and Sidekiq servers (all those are bundled in
  the [Docker image](https://hub.docker.com/r/sameersbn/gitlab/) by
  [Sameer Naik](https://github.com/sameersbn) - Thank you!).

### Problem

The main problem in creating HA apps on K8s/AWS is storage, either in the
form of a database or of a filesystem. The EBS disks that you can attach to
EC2 instances would be the goto solution as Kubernetes can manage those. But
EBS disks live in an availability zone and therefore are not highly available.
You can move data from one AZ to another with snapshots, but this would be
cumbersome.

## Target architecture

To ensure high availability on our Gitlab instance, we will leverage two AWS
services:

* AWS RDS (Relational Database Service) will provide a HA PostgreSQL database,
* AWS EFS (Elastic Filesystem) will provide a HA filesystem available over NFS.

This seems straightforward, but the EFS implementation has a gotcha: you have
a different mount point in each AZ.

The Redis server and Gitlab itself will run as K8s deployments.

Here is what it looks like:

![schema_archi](/img/gitlab-on-k8s/gitlab-on-k8s.png "Architecture")

As you can see on this schema, we will actually have at least one Gitlab
instance per AZ. In each AZ, Gitlab needs to access the EFS storage, but the
mount point changes from one AZ to the other. So, to provide HA, we need at least
2 Gitlab instances using 2 of the EFS mount points.

## Implementation

### AWS resources - Terraform

#### Importing Kops resources

We will use [Terraform](https://www.terraform.io/) to create the AWS resources
we need for Gitlab. We will need to interact with resources created by Kops
(VPC and subnets), so we need to import them in Terraform. Luckily, the
``import`` feature was recently added to Terraform! You just need to run the
following commands with the right IDs:

```bash
terraform import aws_vpc.kops_vpc vpc-xxxxxx
terraform import aws_subnet.kops_suba subnet-xxxxxx
terraform import aws_subnet.kops_subb subnet-xxxxxx
terraform import aws_subnet.kops_subc subnet-xxxxxx
```

Once those commands executed, you must create a ``kops.tf`` file containing
those resources, otherwise Terraform will try to destroy them at the next run
(and keep the tags too!):

```terraform
# Resource managed by KOPS DO NOT TOUCH
resource "aws_vpc" "kops_vpc" {
  cidr_block = "10.0.0.0/22"
  tags {
    Name = "k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}

# Resource managed by KOPS DO NOT TOUCH
resource "aws_subnet" "kops_suba" {
  vpc_id = "${aws_vpc.kops_vpc.id}"
  cidr_block = "10.0.0.128/25"
  tags {
    Name = "eu-west-1a.k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}
# Resource managed by KOPS DO NOT TOUCH
resource "aws_subnet" "kops_subb" {
  vpc_id = "${aws_vpc.kops_vpc.id}"
  cidr_block = "10.0.1.0/25"
  tags {
    Name = "eu-west-1b.k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}
# Resource managed by KOPS DO NOT TOUCH
resource "aws_subnet" "kops_subc" {
  vpc_id = "${aws_vpc.kops_vpc.id}"
  cidr_block = "10.0.1.128/25"
  tags {
    Name = "eu-west-1c.k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}
```
Once you have created this file, you should be able to run a ``terraform plan``
and Terraform should not modify anything.

#### Creating RDS and EFS resources

Once you have imported the networking resources created by Kops, you can
provision what you need for Gitlab in a ``gitlab.tf`` file:

```terraform
variable "node_sg_id" {
  # Here, the security group created by Kops for the worker nodes
  default = "sg-xxxxxx"
}

variable "master_sg_id" {
  # Here, the security group created by Kops for the master nodes
  default = "sg-xxxxxx"
}

resource "aws_efs_file_system" "gitlab_nfs" {
  tags {
    Name = "k8s.myzone.net"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_security_group" "EFS_K8s" {
  name = "EFS_K8s"
  description = "Allow NFS inbound traffic"
  vpc_id = "${aws_vpc.kops_vpc.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups =  ["${var.node_sg_id}", "${var.master_sg_id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "EFS_K8s"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_efs_mount_target" "gitlab_nfsa" {
  file_system_id = "${aws_efs_file_system.gitlab_nfs.id}"
  subnet_id = "${aws_subnet.kops_suba.id}"
  security_groups = ["${aws_security_group.EFS_K8s.id}"]
}
resource "aws_efs_mount_target" "gitlab_nfsb" {
  file_system_id = "${aws_efs_file_system.gitlab_nfs.id}"
  subnet_id = "${aws_subnet.kops_subb.id}"
  security_groups = ["${aws_security_group.EFS_K8s.id}"]
}
resource "aws_efs_mount_target" "gitlab_nfsc" {
  file_system_id = "${aws_efs_file_system.gitlab_nfs.id}"
  subnet_id = "${aws_subnet.kops_subc.id}"
  security_groups = ["${aws_security_group.EFS_K8s.id}"]
}

output "NFS_mount_points" {
  value = "${aws_efs_mount_target.gitlab_nfsa.dns_name} ${aws_efs_mount_target.gitlab_nfsb.dns_name} ${aws_efs_mount_target.gitlab_nfsc.dns_name}"
}

resource "aws_db_subnet_group" "gitlab_pgsql" {
  name = "gitlab_pgsql"
  subnet_ids = ["${aws_subnet.kops_suba.id}", "${aws_subnet.kops_subb.id}", "${aws_subnet.kops_subc.id}"]
  tags {
    Name = "Gitlab PgSQL"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_security_group" "gitlab-pgsql" {
  name = "gitlab-pgsql"
  description = "Allow PgSQL inbound traffic"
  vpc_id = "${aws_vpc.kops_vpc.id}"
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "TCP"
    security_groups =  ["${var.node_sg_id}", "${var.master_sg_id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "gitlab-pgsql"
    KubernetesCluster = "k8s.myzone.net"
  }
}

resource "aws_db_instance" "gitlab-pgsql" {
  allocated_storage       = "50"
  engine                  = "postgres"
  engine_version          = "9.3.14"
  identifier              = "gitlab-pgsql"
  instance_class          = "db.t2.medium"
  storage_type            = "gp2"
  name                    = "gitlab_production"
  password                = "yourpassword"
  username                = "gitlab"
  backup_retention_period = "30"
  backup_window           = "04:00-04:30"
  maintenance_window      = "sun:04:30-sun:05:30"
  multi_az                = true # <= important!
  port                    = "5432"
  vpc_security_group_ids  = ["${aws_security_group.gitlab-pgsql.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.gitlab_pgsql.name}"
  storage_encrypted       = false
  auto_minor_version_upgrade = true

  tags {
    Name        = "gitlab-pgsql"
    KubernetesCluster = "k8s.myzone.net"
  }
}

output "PgSQL_endpoint" {
  value = "${aws_db_instance.gitlab-pgsql.endpoint}"
}
```

After running a ``terraform plan/apply``, the NFS and PostgreSQL endpoints
should be displayed.

What does this code create?

* A RDS/PostgreSQL instance with multi-AZ enabled for HA,
* An EFS filesystem and its associated endpoints in each AZ,
* The needed security groups for everything.

### Kubernetes resources

Once everything we need is created on AWS, we can create what we need in K8s!

For each piece of yaml code in this post, you can create the resources they
describe by puting the code in a ``file.yaml`` file and running ``kubectl apply
-f file.yaml``.

#### Persistent Volumes
Let's start with the ``PersistentVolume`` objects. As we have 3 EFS endpoints,
we need 3 ``PersistentVolumes``, even if it is to access the same data. Note
that we label each PV with the AZ: we will use those labels to choose which PV
to use in the Gitlab deployments.

In the declaration of the PVs, you will have to use the EFS endpoints given
by your previous Terraform run.

```yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab.data.efs.a
  labels:
    usage: gitlab-data
    zone: eu-west-1a
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: eu-west-1a.fs-xxxxxx.efs.eu-west-1.amazonaws.com
    path: "/"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab.data.efs.b
  labels:
    usage: gitlab-data
    zone: eu-west-1b
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: eu-west-1b.fs-xxxxxx.efs.eu-west-1.amazonaws.com
    path: "/"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gitlab.data.efs.c
  labels:
    usage: gitlab-data
    zone: eu-west-1c
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: eu-west-1c.fs-xxxxxx.efs.eu-west-1.amazonaws.com
    path: "/"
```

#### Redis

We don't need a complicated setup for Redis, so let's do the simplest we can:

```yaml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: redis
    spec:
      containers:
      - name: redis
        image: redis
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  ports:
  - port: 6379
    protocol: TCP
    targetPort: 6379
  selector:
    name: redis
```

The ``Deployment`` will ensure that we always have a Redis server (``replicas:
1``), and the ``Service`` will allow to access the Redis server by simply using
``redis`` as address.

#### Gitlab Deployment

As said previously, we need at least 2 Gitlab instances, spread over 2 AZs. So
we will create one Gitlab Deployment per AZ. Here is the code for AZ ``a``, for
AZs ``b`` and ``c,`` just copy and paste + change ``a`` by ``b`` or ``c`` where needed.

Two important things to note:

* We use [environment variables](https://docs.gitlab.com/ce/administration/environment_variables.html)
  to configure the Gitlab Docker image, and the
  passwords are stored as K8s ``secrets``. Secrets are base64-encoded data, so
  don't put them in your Git repository.
* In each deployment, everything is restricted to the target AZ, so we need to
  filter the resources we use with labels and selectors.

For instance, the ``PersistentVolumeClaim`` will use the following selector that
will help to choose the EFS endpoint of AZ a:

```yaml
selector:
  matchLabels:
    usage: gitlab-data
    zone: eu-west-1a
```

Similarly, we need to restrict the Gitlab deployment to an AZ, so we select the
nodes on which to run:

```yaml
nodeSelector:
  failure-domain.beta.kubernetes.io/zone: eu-west-1a
```

Here is the complete code for a single AZ:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-secrets
type: Opaque
data:
  db-key-base: base64-encoded-key
  secret-key-base: base64-encoded-key
  otp-key-base: base64-encoded-key
  db-pass: base64-encoded-password
  root-pass: base64-encoded-password
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: gitlab.data.efs.a
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  selector:
    matchLabels:
      usage: gitlab-data
      zone: eu-west-1a
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: gitlab-a
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: gitlab-a
        app: gitlab
    spec:
      nodeSelector:
        failure-domain.beta.kubernetes.io/zone: eu-west-1a
      containers:
      - name: gitlab-a
        image: sameersbn/gitlab:8.12.6
        imagePullPolicy: Always
        ports:
        - containerPort: 80
        env:
        - name: TZ
          value: Europe/Paris
        - name: GITLAB_TIMEZONE
          value: Paris
        - name: GITLAB_SECRETS_DB_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: gitlab-secrets
              key: db-key-base
        - name: GITLAB_SECRETS_SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: gitlab-secrets
              key: secret-key-base
        - name: GITLAB_SECRETS_OTP_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: gitlab-secrets
              key: otp-key-base
        - name: GITLAB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: gitlab-secrets
              key: root-pass
        - name: GITLAB_HOST
          value: git.default.cluster.local
        - name: GITLAB_PORT
          value: "80"
        - name: GITLAB_SSH_PORT
          value: "22"
        - name: GITLAB_NOTIFY_ON_BROKEN_BUILDS
          value: "true"
        - name: GITLAB_NOTIFY_PUSHER
          value: "false"
        - name: DB_TYPE
          value: postgres
        - name: DB_HOST
          # Value given by Terraform
          value: gitlab-pgsql.xxxxxx.eu-west-1.rds.amazonaws.com
        - name: DB_PORT
          value: "5432"
        - name: DB_USER
          value: gitlab
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: gitlab-secrets
              key: db-pass
        - name: DB_NAME
          value: gitlab_production
        - name: REDIS_HOST
          value: redis
        - name: REDIS_PORT
          value: "6379"
        ports:
        - name: http
          containerPort: 80
        - name: ssh
          containerPort: 22
        volumeMounts:
        - mountPath: /home/git/data
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 180
          timeoutSeconds: 5
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          timeoutSeconds: 1
        volumes:
          - name: data
            persistentVolumeClaim:
              claimName: gitlab.data.efs.a
```

#### Gitlab Service

Almost finished! When the 3 Gitlab deployments are created, you can tie them
together with a single service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: gitlab
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  - name: ssh
    port: 22
    protocol: TCP
    targetPort: 22
  selector:
    app: gitlab
  type: LoadBalancer
```

Note the ``type: LoadBalancer``: it will automatically create an AWS ELB to make
Gitlab accessible from the outside world!

## Conclusion

Well, that was a lot! But you now have a highly available Gitlab, that you can
scale easily if needed! Only a few things are missing to have a state of the art
Gitlab installation: HTTPS and Gitlab runners for GitlabCI (maybe more on that
in a future post).

The main thing to remember is that it is possible to host stateful applications
on Kubernetes, provided you have a HA storage backend. In this case, we use both
AWS RDS and EFS and we have to work around some EFS properties, but this method
could be applied to a whole range of applications. Understanding the underlying
principles of this setup will allow you to apply them to your own use-case.
