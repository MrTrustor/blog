+++
date = "2017-01-02"
draft = false
title = "AWS re:Invent 2016 - A recap (part II)"
tags = ["aws","reinvent"]
[header]
image = "aws-reinvent-2016-a-recap-part1/header.png"
+++

This is the second and last part of my AWS re:Invent recap. Go check out the
[first part](/post/aws-reinvent-2016-a-recap-part1/) if you haven't done so
already.

![announcements](/img/aws-reinvent-2016-a-recap-part1/announcements.jpg)

In this second post, I will outline the products announced by Werner Wogels
during his [keynote](https://www.youtube.com/watch?v=ZDScBNahsL4). You will also
find a small opinionated analysis of the impact of each product, based on the
current market and ecosystem.

I tagged the really important ones with a ``[Game Changer]`` in the title.

---

## Compute

This year, AWS really pushed its advantage in the serverless market where they
are leading even more clearly than in other fields.

### C# in AWS Lambda

According to AWS, this was a feature highly requested by customers. So now, AWS
Lambda supports 4 languages: Javascript, Python, Java and C#.

I would have preferred an "agnostic" Lambda runtime where you could have run
any binary (or container), but another language is always good to take.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/compute/announcing-c-sharp-support-for-aws-lambda/)

### AWS Lambda@Edge [Preview only]

You can now run Lambda functions (in Javascript) at AWS's edge locations, in
response to Cloudfront events. You can manipulate the request and the response
directly at the edge location, avoiding the round-trip to the origin, for a
better latency.

This is a very interesting next-step for Cloudfront. This kind of feature is
almost certainly the future of CDNs.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/coming-soon-lambda-at-the-edge/)
* [AWS Doc](http://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html)

### AWS Step Functions [Game Changer]

Step Functions clearly was the product that AWS was pushing the most, because it
takes the serverless paradigm a step further.

AWS Step Functions allows to connect Lambda functions with each other to
implement a real, complex application. You can implement classic paradigms such
as loops, retries, etc. You can also poll for long-running jobs.

![step_functions](/img/aws-reinvent-2016-a-recap-part2/stepfunctions.png)

No one else has a product that does this, and it certainly is an answer to the
biggest problem of serverless: it's really hard to implement complex
applications. Now you can easily link functions while keeping them independent,
and scalable.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/new-aws-step-functions-build-distributed-applications-using-visual-workflows/)

### Blox

If AWS is the leader in the serverless world, it clearly missed the container
battle. ECS is light years behind other solutions such as Kubernetes or
Mesos/Marathon. So much so that, before re:Invent, there was chatter about a
possible Kubernetes-as-a-Service (or at least etcd-as-a-Service),
announcement that would come in direct competition with Google's GKE.

AWS being AWS, they did not choose this route and unexpectedly released an
open-source project: [Blox](https://blox.github.io/).

![blox](/img/aws-reinvent-2016-a-recap-part2/blox.png)

Blox is a framework for container management and orchestration on ECS (which is,
of course, not open-source). In other words, it gives you the ability to create
your own tools on top of ECS. Right now, two exist and have been released
directly by AWS:

* ``cluster-state-service``: this exposes an API of all events occurring on the
ECS cluster.
* ``daemon-scheduler``: this allows to run exactly one replica of your task per
host on the cluster (ideal for logs or monitoring).

This is accompanied by a few changes on ECS such as the ability to label your
nodes and allocate workloads according to those labels.

While Blox is in theory a good idea, it is probably too complicated for most
people to implement those kind of tools. Right now, it only has a really small
subset of the features that the competitors have and I don't see this project
gaining enough traction to ever catch up. It feels like AWS is throwing all of
its power in the serverless battle while doing the bare minimum on the container
front.

As a side note, it is interesting to note the open-source nature of Blox. AWS is
known for having a very ambivalent attitude towards open-source: on one side,
they clearly use it a lot and cater to the open-source community, but on the
other side, they almost never release their own tools and it is notoriously
difficult for Amazon employees to contribute to open-source projects. It would
be nice if Blox was the beginning of Amazon's policy change, but I honestly
doubt it.

References:

* [Blox official site](https://blox.github.io/)

---

## Security

### AWS Shield

AWS Shield is an integrated anti-DDoS product. When it was announced, many
people, myself included, said "Huh?! Doesn't AWS do that already?". Here is the
catch: there are 2 service levels to Shield: Standard and Advanced.

* Shield Standard is free and enabled for all customers. It protects against the
most common DDoS attacks on ELBs, CloudFront and Route53.
* Shield Advanced is expensive ($3000/month, 1 year commitment + data transfer).
It comes with some interesting features:
 * Visibility and reporting on the attacks,
 * Cost protection (i.e you are not charged for resources used to mitigate an
   attack),
 * A response team and support from AWS that can help you mitigate attacks,
   advise you on best practices and help you configure services such as AWS WAF.

It is my supposition that AWS already had an anti-DDoS service but never
advertised it. Naming it publicly "Shield Standard" allowed them to
commercialize the "Advanced" version.

The cost of the Advanced tier is quite high, so the potential users are
probably already big AWS customers (or companies with large budgets) and
websites that "naturally" attract those kinds of attacks.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/aws-shield-protect-your-applications-from-ddos-attacks/)

---

## EC2 ecosystem

### AWS OpsWorks For Chef Automate

AWS OpsWorks For Chef Automate is probably the worst name ever for a product, so
I will call it AWS OFCA in this article. It comes along the old AWS OpsWorks
that has been renamed AWS OpsWorks Stacks.

AWS OFCA is a managed Chef-Server. Chef-Server allows you to store cookbooks and
configuration for your nodes. The Chef client then runs on the nodes and connect
to the Chef-Server to get their configuration and the needed cookbooks.
You can use Chef outside AWS, but OpsWorks allows to integrate with other AWS
services such as autoscaling.

I am a big Chef user, so AWS OFCA is of great interest to me, but I haven't had
the time to test this product yet. If you are already using Chef, it probably is
a good solution. If you are not, you probably want to compare Chef to other
projects such as Puppet, Ansible, Salt-Stack (or even Docker) before making a
choice.

References:

* [AWS Product Details](https://aws.amazon.com/opsworks/chefautomate/details/?nc1=h_ls)

### Amazon EC2 Systems Manager

EC2 Systems Manager encompasses the EC2 Run Command API and adds other features
that allows you to manage your EC2 and on-premise fleet.

* **Run Command**: runs a command on all or a subset of your nodes.
* **Sate Manager**: maintains a defined system configuration via policies that
are applied at regular intervals.
* **Parameter Store**: centralizes storage for parameters (licenses, passwords,
  user lists, etc.).
* **Maintenance Window**: allows you to specify a time window for installation
of updates and other system maintenance.
* **Software Inventory**: gathers a detailed software and configuration
inventory (with user-defined additions) from each instance.
* **AWS Config Integration**: based on Software Inventory, AWS Config can now
record software inventory changes.
* **Patch Management**: automates the patching process for your instances.
* **Automation**: simplifies AMI building and other recurring AMI-related tasks.

I am ambivalent towards this product: on one side it provides some features that
the AWS ecosystem clearly lacked, but on the other side most, if not all of
them, have already been successfully implemented by other open-source tools.

Most of them also target non-immutable infrastructures (i.e long-running
instances whose configuration can change during their lifetime) whereas the best
practice is clearly represented by immutable infrastructures where instances are
short-lived and never modified once launched.

I feel like migrating from other tools such as Packer or Ansible to those
requires a lot of work and I am not sure if it's worth it.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/category/ec2-systems-manager/)

### AWS Personal Health Dashboard

On this dashboard, you can see all the AWS events that are related to the
services you are using. If there is a maintenance planned on a host one of your
nodes is running on, you will see it here. If there was a problem on your RDS
instance, it will be displayed with some contextual help. You can also automate
the response to some events via CloudWatch Events.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/new-aws-personal-health-dashboard-status-you-can-relate-to/)

---

## Software lifecycle

AWS was missing a few pieces in this field. The introduction of those 2 new
products is filling those gaps and clearly indicates that AWS wants to have
a product available for your every need.

### AWS CodeBuild

AWS CodeBuild comes to the already crowded market of the CI tools. As such, it
is a direct competitor of Jenkins, Travis CI or Gitlab CI. It allows you to run
a continuous integration/deployment (CI/CD) pipeline in a managed environment.

You configure your source code location and what you want to do in your build
(via a Yaml file) and CodeBuild takes care of the rest. It can build projects
for Android, Java, Python, Ruby, Go, Node.js or Docker.

CodeBuild is interesting but there is a very strong competition in this field
and I am not sure the features are good enough to make a real difference.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/aws-codebuild-fully-managed-build-service/)

### AWS X-Ray [Preview]

AWS X-Ray is an Application Performance Management (APM) tool. It comes on the
territory of tools like NewRelic or AppDynamics. It can capture data directly
from your application and a number of AWS services such as ELBs. It gives you a
nice global view of the health of your application, infrastructure included.

However, X-Ray is compatible with a small number of languages: NodeJS, Java, C#,
.NET and for Lambda. Moreover, to get anything meaningful from inside your
application, you need to instrument it yourself. For instance, for NodeJS, you
have 3 different pieces of code to include to monitor incoming requests,
AWS API calls and outgoing HTTP calls. You can also send custom traces via
another API call.

```javascript
var AWSXRay = require('aws-xray-sdk');

app.use(AWSXRay.express.openSegment());

app.get('/', function (req, res) {
  var host = 'api.example.com';

  AWSXRay.captureAsync('send', function(subsegment) {
    sendRequest(host, function() {
      console.log('rendering!');
      res.render('index');
      subsegment.close();
    });
  });
});

app.use(AWSXRay.express.closeSegment());

function sendRequest(host, cb) {
  var options = {
    host: host,
    path: '/',
  };

  var callback = function(response) {
    var str = '';

    response.on('data', function (chunk) {
      str += chunk;
    });

    response.on('end', function () {
      cb();
    });
  }

  http.request(options, callback).end();
}
```

It feels like the competitors are much easier to use and have a wider range of
supported technologies.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/aws-x-ray-see-inside-of-your-distributed-application/)
* [X-Ray documentation](http://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html)

---

## Others

Those are products that I could not put in any of the other categories, but it
doesn't mean they are not important!

### Amazon Pinpoint

Pinpoint is a service for managing notifications on a mobile app. You can send
notifications to specific groups of users, based on a variety of parameters. It
also gives you analytics and reporting on the effect of your notifications.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/amazon-pinpoint-hit-your-targets-with-aws/)

### AWS Glue [Coming soon]

Glue is a managed ETL (Extract, Transform, Load) tool. You define data sources
and targets (S3, RDS, Redshift or others), specify transformations to be applied
to this data (Glue will generate some working Python code that you can modify)
and finally you create and schedule jobs.

Glue has the potential to be a very interesting service, but there are not
enough details at the moment to give a more definitive opinion.

References:

* [AWS Glue Homepage](https://aws.amazon.com/glue/)

### AWS Batch [Game changer]

AWS Batch is a service that makes batch computing easier. With Batch, you can
run jobs on both managed and unmanaged infrastructures, but most of the
advantages come from using managed infrastructures. It allows you to define
broad requirements for a job (like "this job is memory or CPU-bound") and it
will provision the right instances for you. Another very good feature is the
integration of Spot Instances where you can say "Run those jobs only if the
spot price falls below 20% of the on-demand price".

There are a lot of concepts in Batch, so instead of explaining everything, I
will redirect you to this video from the AWS team that I feel is a very good
visual representation of the service:

<iframe width="560" height="315" src="https://www.youtube.com/embed/ebwfhSS4ZkY?start=1571&end=1712" frameborder="0" allowfullscreen></iframe>

I really like this service and think it can greatly ease the management of a
number of workloads.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/aws-batch-run-batch-computing-jobs-on-aws/)
