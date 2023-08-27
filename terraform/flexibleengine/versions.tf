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

# terraform {
#   required_version = ">= 0.13"
#     time = {
#       source = "hashicorp/time"
#     }
#   }

#Configure the FlexibleEngine Provider
provider "flexibleengine" {
 #domain_name = "OCB0003296"
# access_key   = "ACCESS_KEY_ID"
# secret_key    = "SECRET_ACCESS_VALUE"
 #region      = "eu-west-0"
}
