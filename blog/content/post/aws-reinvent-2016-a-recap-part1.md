+++
date = "2016-12-17"
draft = true
title = "AWS re:Invent 2016 - A recap (part I)"
image = "aws-reinvent-2016-a-recap-part1/header.png"
tags = ["aws","reinvent"]
+++

Two weeks ago, thanks to my company, [Oxalide](http://www.oxalide.com), I had the chance to attend AWS re:Invent, at Las Vegas. This is the first part of a recap of all the [announcements](https://aws.amazon.com/new/reinvent/?nc1=h_ls) (yes, there are so many things to talk about that it doesn't fit in a single post). You will also find a small opinionated analysis of the impact of each product, based on the current market and ecosystem.

![announcements](/img/aws-reinvent-2016-a-recap-part1/announcements.jpg)

In this first post, I will outline the products announced by Andy Jassy during his [keynote](https://www.youtube.com/watch?v=8RrbUyw9uSg). In the second post, I will talk about the announcements made by Werner Wogels.

I tagged the really important ones with a ``[Game Changer]`` in the title.

---

## Compute

AWS is still clearly the leader on this field and keeps innovating with more and more diverse products for all use cases.

### Elastic GPUs for EC2 [Preview Only]

This features allows to add a GPU to an EC2 instance the same way you add an EBS volume. You have 4 GPUs available: from eg1.medium (1GiB of RAM) to eg1.2xlarge (8GiB of RAM). However, right now the only library that will detect and use to GPUs is a custom **Windows** OpenGL library. Support for the Amazon Linux AMI has been announced.

**Analysis** - While this is a nice feature that no other Cloud provider offers, the use cases are  very narrow:

* Windows only
* Workload that you don't want or can't run on a G2 or P2 instance.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/in-the-work-amazon-ec2-elastic-gpus/)

### F1 instances [Preview only, Game Changer]

The EC2 F1 instances have field programmable gate arrays (FGPAs) that can be used to create custom hardware accelerations. This comes with the possibility to sell your F1 instances and their already customized FGPAs on the AWS Marketplace.

**Analysis** - Once again, no other cloud provider offers an equivalent product. The fact that you can sell your own work on FGPAs on the AWS Marketplace demonstrates once again the capacity of AWS to create new industries from scratch: I am sure that in the coming months, at least a few companies will be created solely for that.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/ec2-instance-type-update-t2-r4-f1-elastic-gpus-i3-c5/)

### Amazon Lightsail

This is AWS new "beginner" product. Lightsail is a simple Virtual Private Server (VPS) offer that can come with applications such as Wordpress or Gitlab preinstalled. The price starts at $5 a month for the equivalent of a t2.nano (512MB RAM - 1 vCPU).

**Analysis** - An interesting move, designed to facilitate the entry into the complex AWS world. It makes me think of chocolate cigarettes for kids. While $5/month seems cheap, the server is ridiculously small. For instance, to host Gitlab in correct conditions, you would need the $40 or $80 options. There are far cheaper solutions for VPSs out there.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/amazon-lightsail-the-power-of-aws-the-simplicity-of-a-vps/)
* [Amazon Lightsail](https://amazonlightsail.com/)

### AWS Greengrass [Preview Only]

Greengrass is a service that allows you to run Python Lambda Functions locally. It is intended to be used on IoT devices that have limited connectivity and bandwidth to allow them to (pre)process the data they generate locally. It is already present in the new AWS Snowball Edge.

**Analysis** - AWS is pushing hard on both IoT and Serverless. Greengrass is the symbiosis of the two and feels quite natural as a product. I am sure it will find its market.

---

## BigData

### Amazon Athena [Game Changer]

This is a very interesting one. Athena allows you to run SQL queries directly on data in S3, without any other database service such as RDS or DynamoDB.

You point Athena to a S3 bucket, you indicate how the data is structured, and _voilà_!

**Analysis** - On conditions of good performances (which I have not yet tested), this has the potential of changing the whole BigData analysis field because of the simplicity: put your data in S3 (don't worry about setup, scale, redundancy or anything) and that's it, you have your datalake ready for analysis.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/amazon-athena-interactive-sql-queries-for-data-in-amazon-s3/)

---

## Artificial Intelligence

AWS is making a strong push in the Artificial Intelligence/Machine learning field, to close the gap with Google on this market. Overall, the products are interesting, but I am not sure they quite compete with Google's right now.

### Amazon Rekognition

Rekognition is an API that uses AI to describe the content of pictures and analyze the faces (if any) on the pictures.

Here I am, a few days after reInvent:

![death_valley](/img/aws-reinvent-2016-a-recap-part1/death_valley.jpg)

Here is the description of Rekognition:

```json
{
    "Labels": [
        {
            "Confidence": 99.32511138916016,
            "Name": "Human"
        },
        {
            "Confidence": 99.3255844116211,
            "Name": "People"
        },
        {
            "Confidence": 99.3255844116211,
            "Name": "Person"
        },
        {
            "Confidence": 91.1029052734375,
            "Name": "Cardigan"
        },
        {
            "Confidence": 91.1029052734375,
            "Name": "Clothing"
        },
        {
            "Confidence": 91.1029052734375,
            "Name": "Sweater"
        },
        {
            "Confidence": 88.43571472167969,
            "Name": "Dune"
        },
        {
            "Confidence": 88.43571472167969,
            "Name": "Outdoors"
        },
        {
            "Confidence": 64.95654296875,
            "Name": "Desert"
        },
        {
            "Confidence": 57.82466125488281,
            "Name": "Beach"
        },
        {
            "Confidence": 57.82466125488281,
            "Name": "Coast"
        },
        {
            "Confidence": 57.82466125488281,
            "Name": "Sea"
        },
        {
            "Confidence": 57.82466125488281,
            "Name": "Water"
        },
        {
            "Confidence": 55.57418441772461,
            "Name": "Leisure Activities"
        },
        {
            "Confidence": 50.69664764404297,
            "Name": "Dimples"
        },
        {
            "Confidence": 50.69664764404297,
            "Name": "Face"
        },
        {
            "Confidence": 50.69664764404297,
            "Name": "Smile"
        }
    ]
}
```

If the firsts elements are ok, "Beach", "Coast", "Sea" and "Water" are way off, given that this picture was taken in the Death Valley. Also, "Dimples"?! Thank you very much Rekognition :-)!

Here is the result of Google Cloud Vision API as a comparison:

![vision_api](/img/aws-reinvent-2016-a-recap-part1/vision_api.jpg)

**Analysis** - AWS is here trying to close the gap with GCP on Artificial Intelligence. Rekognition is not as good as Vision API right now (most notably concerning face analysis), but let's see how the service improves with time.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/amazon-rekognition-image-detection-and-recognition-powered-by-deep-learning/)

### Amazon Polly

Polly is a text-to-speech (TTS) service. The produced speech is quite life-like, and they use some pretty advanced methods to reduce the "robotic" feel by, for example, linking the pronounced word together as a human would do. You can also indicate how to pronounce given words. For instance, I can say to Polly that "Théo" is pronounced ``teo`` and not ``Théəʊ``.

The service is available in 24 languages. If the English seemed pretty good to me, the French speech was clearly not as life-like.

**Analysis** - To my knowledge, Google does not have a public TTS API (but you can "hack" Google Translate for that), but it does have a speech to text API, Speech API, that works very well. So, here, the 2 companies are not in direct competition, even if it probably will come.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/polly-text-to-speech-in-47-voices-and-24-languages/)

### Amazon Lex [Preview Only]

Lex is the core of Alexa, Amazon's virtual assistant. This service allows you to build conversational interfaces. Here is how it works:

* You define possible actions that your user can do with your bot,
* You declare what information you need to complete the actions,
* You specify the lambda function to be launched to execute the action once the bot has all the information needed.

**Analysis** - This is certainly interesting, event if I am not a hundred percent confident that conversational interfaces are the future as long as [general AI](https://en.wikipedia.org/wiki/Artificial_general_intelligence) does not exist. As far as I am aware, Lex is the first product of its kind.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/amazon-lex-build-conversational-voice-text-interfaces/)

---

## Migrations

For people who really have a **lot** of data.

### AWS Snowball Edge

Snowball Edge is the version 2 of Snowball. A service to send data to AWS in a physical box, via a company such as UPS.

The new Snowball Edge has more capacity (100TB), but the other features are more interesting:

* Snowball Edge can "speak" S3 or NFS. So if you have tools to store data with those protocols, you can use them.
* Clustering of several Snowballs.
* Local compute in Python via Lambda (and Greengrass), which means you can pre-process data locally before it is sent to AWS.

The example given by Andy Jassy during the keynote was the one of a scientific boat: store all the retrieved data on Snowball Edge, do a first analysis with Greengrass to have preliminary results, and once the boat goes back to mainland, send the Snowball back to do the full analysis.

**Analysis** - Snowball definitely has its uses. While you can send data on a physical drive to both Microsoft or Google, neither has a service equivalent to Snowball.

When AWS announced Greengrass on Snowball Edge, I must admit I failed to see the use case, but the example given shows that it can be useful in particular situations.

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/aws-snowball-edge-more-storage-local-endpoints-lambda-functions/)

### AWS Snowmobile

If the Snowball Edge is not big enough for you, AWS can now send a literal 100PB truck to your datacenter with a power generator and security guards. No kidding. That's it, enough said.

![snowmobile](/img/aws-reinvent-2016-a-recap-part1/snowmobile.jpg)

References:

* [AWS Blog Post](https://aws.amazon.com/blogs/aws/aws-snowmobile-move-exabytes-of-data-to-the-cloud-in-weeks/)

---

## Databases

### Aurora PostgreSQL compatibility [Game Changer]

Until now, Aurora was a very good MySQL solution. It also now is a very good PostgreSQL solution. The advantages of Aurora are quite complex to explain and out of the scope of this post, but suffice to say that it performs and scales better than a classic MySQL or PostgreSQL.

**Analysis** - There is some bad blood between Oracle and AWS (the trolling during reInvent was quite intense). Aurora PostgreSQL was a highly requested feature and AWS has delivered. But it is also openly a move against Oracle. But I am happy, Aurora and PostgreSQL are both good products: the combination of the two will be great I hope!
