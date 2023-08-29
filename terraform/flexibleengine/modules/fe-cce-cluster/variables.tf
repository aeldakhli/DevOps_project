variable "key_pair" {}
variable "vpc-id" {}
variable "cluster-description" {
  default = "DevOps Project Cluster"
}
variable "cluster-provisioning-type" {
  default = "VirtualMachine"
}
variable "cce-node-type" {
    description = "Value can be vm or bms"
    default = "vm"
}
variable "flavor_id" {
    default = "cce.s1.small"
}
variable "cluster_k8s_version" {
  default = "v1.25"
}
variable "network-type" {
    default = "vpc-router"
}
variable "cluster-name" {}
variable "pool-name" {}
variable "container-network" {
    default = "172.16.0.0/16"
}
variable "auth-mode" {
    default = "rbac"
}
variable "container-subnet-id" {}
variable "os-name" {
 default = "EulerOS 2.9"  
}
variable "pool-nodes-number" {
    type = number
    default = 2
}
variable "node-flavor" {
  default = "s3.large.4"
}
variable "avail-zone" {
  default = "eu-west-0c"
}
variable "node-rootvol-size" {
    type = number
    default = 40
}
variable "node-datavol-size" {
    type = number
    default = 200
}
variable "vol-type" {
  default = "SAS" 
}