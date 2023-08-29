# Module specifications:

## Module variables:
+ Below are the module variables:
 - bastion-name: Name of the instance that will be created default is "Bastion" and type is string
 - bastion-disk-size: The EVS Disk Size default is "100" type is number
 - sec_grp_name: Security group name
 - sg-description: Security group description, default is "Jump Server SG"
 - jump-image_name: Jump server image name default is "OBS CentOS 7.9"
 - jump-flavor: Jump server flavor default is "s3.large.2"
 - key_pair: Key pair namr
 - bastion-subnet-id: Subnet ID for basion server

## Module required provider & version:

It uses terrafor version >= 0.13 and FlexibleEngineCloud/flexibleengine provider version >= 1.30.0

below is a sample configuration:

```
terraform {
  required_version = ">= 0.13"

  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
      version = ">= 1.30.0"
    }
  }
}
```