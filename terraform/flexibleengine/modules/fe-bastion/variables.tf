variable "bastion-name" {
  description = "Name of the instance that will be created"
  default = "Bastion"
  type = string
}

variable "bastion-disk-size" {
  description = "EVS Disk Size"
  default = 100
  type = number
}

variable "sec_grp_name" {}
variable "sg-description" {
  default = "Jump Server SG"
}
variable "jump-image_name" {
  default = "OBS CentOS 7.9"
}
variable "jump-flavor" {
  default = "s3.large.2"
}
variable "key_pair" {}
variable "bastion-subnet-id" {}