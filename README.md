# ProwlerPro SaaS Permission Templates
This repo holds the templates that creates the required permissions in a customer's account to be scanned by ProwlerPro SaaS:

- [CloudFormation Template](./cloudformation/prowler-pro-scan-role.yaml)
- [Terraform template](./terraform/main.tf)

## Templates Description

- The above templates creates a role named `ProwlerProSaaSScanRole` and will be assumed from our account having as principal the roles used by ProwlerPro.

## Deployment using CloudFormation

For the CFN deployment we have the following Quick Links:

https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/create/review?templateURL=https://s3.eu-west-1.amazonaws.com/prowler-pro-saas-pro-artifacts/templates/prowler-pro-scan-role.yaml&stackName=ProwlerProSaaSScanRole&param_ExternalId=YourExternalIDHere

## Deployment using Terraform

To deploy the ProwlerPro SaaS Role in order to allow to scan you AWS account, please run the following commands in your terminal:
1. `terraform init`
2. `terraform plan`
3. `terraform apply`

During the `terraform plan` and `terraform apply` steps you will be asked for your AWS External ID.
