#provider.tf
terraform {
  required_version = ">= 0.13"

  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
      version = ">= 1.30.0"
    }
  }
}
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

# terraform {
#   required_version = ">= 0.13"
#     time = {
#       source = "hashicorp/time"
#     }
#   }

#Configure the FlexibleEngine Provider
#provider "flexibleengine" {
 #domain_name = "OCB0003296"
# access_key   = "ACCESS_KEY_ID"
# secret_key    = "SECRET_ACCESS_VALUE"
 #region      = "eu-west-0"
#}
