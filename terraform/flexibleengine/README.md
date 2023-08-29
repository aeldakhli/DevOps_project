# Use case

> [!WARNING]
> This has been adjusted to work with Terraform Cloud. Integration is adjusted to run planning once a push is done for a spesifc path.

The versions.tf has been adjusted as per the Terraform Workspace configurations and variables. So, in case you want to copy the code, you have to comment the below block and source your environmet access variables.

```
# Access Environmental Variables
variable "OS_ACCESS_KEY" {}
variable "OS_SECRET_KEY" {}
variable "OS_AUTH_URL" {}
variable "OS_DOMAIN_NAME" {}
variable "OS_PROJECT_NAME" {}
variable "OS_REGION_NAME" {}

#Configure the FlexibleEngine Provider
provider "flexibleengine" {
 domain_name = var.OS_DOMAIN_NAME
 access_key   = var.OS_ACCESS_KEY
 secret_key    = var.OS_SECRET_KEY
 region      = var.OS_REGION_NAME
 tenant_name = var.OS_PROJECT_NAME
}
```