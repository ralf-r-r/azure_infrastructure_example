# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

## Introduction
This project creates infrastructure as code in the form of a Terraform template to deploy a website with a load balancer.

## Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

## Getting Started
1. Clone this repository
2. Set the environment variables
3. Deploy the tagging-policy
4. Run packer to create the server image
5. Set or modify the terraform variables
6. Run terraform to deploy the infrastructure

## Instructions

### Set the Environment Variables

**Set the following environment variables:**
```
export ARM_SUBSCRIPTION_ID=<your arzue subscription id>
export ARM_CLIENT_ID=<your arzue client id>
export ARM_CLIENT_SECRET=<your arzue client secret>
export ARM_TENANT_ID=<your arzue tenant id>
```

**Get the Client Id**
- Create an Azure Active Directory Application
- Login to Azure Portal if you are not already logged in.
- Search for Azure Active Directory
- From left Menu of Azure Directory Overview -> clickApp registrations -> Click + New Registration.
- Enter your application name. Optionally you can enter the Redirect URI to get Authentication response. Click on Register.
- The Azure Client Id is the Active Directory Application Id. Client Id is the unique identifier of an application created in Active Directory. You can have many applications in an Active Directory. Each application will have a different access level.

**Get the Client Secret Id**
- Login to Azure Portal if you are not already logged in.
- Search for Azure Active Directory
- From left Menu of Azure Directory -> click App Registration -> Click the name of the application created in the previous step
- From the left menu click Certificates & secrets
- Click on New Client Secret from right side pane -> Add description and expiration in Add a Client Secret screen -> Click Add button. Copy value.

**Get the Subscription Id**
- Login to Azure Portal if you are not already logged in.
- Search for Subscriptions, click on your subscription and copy the Id

**Get the Tenant Id**
- Login to Azure Portal if you are not already logged in.
- Go to Azure Active Directory. Under Manage, click Properties. The tenant ID is shown in the Directory ID box.
- 
### Create an Azure User
If you have not created a new azure user run the follwing:
```az ad sp create-for-rbac -role Contributor -name udacityproj1```

### Deploy the Tagging Policy
Create the policy using the follwowing command:
```az policy definition create --name tagging-policy --display-name "TaggingPolicy" --description "This policy prevent the creation of resources without Tags" --rules azurepolicy.json --mode Indexed```

### Build the Server Image Using Packaer

Run the following command:
```packer build server.json```

You can check the creted images and the delete image with these commands:

- ```az image list```
- ```az image delete -g <the resource group> -n <the packer image name>```


### Deploy the Infrastructure Using Terraform

**Prepare your directory for terraform**

```terraform init```

**Set the proper values in var.tf**

- prefix: The prefix which should be used for all resources in this example
- resource_group_name: The azure resource group name that contains the packer image
- vm_size: The size of the vm
- number_vm: The number of virtual machines

**Deploy the infrastructure**

- ```terraform plan -out solution.plan```
- ```terraform apply "solution.plan"```

**Destroy the infrastructure**

```terraform destroy```


