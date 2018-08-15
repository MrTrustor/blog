+++
title = "Creating a Shared VPC with Deployment Manager"
date = 2018-02-01T00:00:00
draft = false

authors = ["Théo Chamley"]

publication = "Google Cloud website"

abstract = "In large organizations, you may need to put different departments or different applications into different projects to separate budgeting, access control, and so on. With Shared VPC, Organization administrators can give multiple projects permission to use a single, shared VPC network and corresponding networking resources. With Shared VPC, as an Organization administrator, you can allow the network and security admins of your organization to manage a VPC network of RFC 1918 IP spaces (and related features such as VPNs or firewall rules) that associated projects can use. Administrators in associated projects can create virtual machine (VM) instances in the shared VPC network space. You can apply and enforce consistent policies across an organization. Because Shared VPC is often used in large organizations, or in organizations with strict security rules, being able to easily reproduce a Shared VPC setup is important. You can use Deployment Manager, an Infrastructure as Code (IaC) tool, to achieve this."

url_custom = [{name = "Tutorial", url = "https://cloud.google.com/solutions/shared-vpc-with-deployment-manager"}]
url_code = "https://github.com/GoogleCloudPlatform/deploymentmanager-samples/tree/master/examples/v2/project_creation"

+++
