# Module specifications:

## About the module
 - This module has been prepared by Ahmed ElDakhli for creating CCE resource on OBS Flexible Engnie Cloud.
 - It is considring false auto scaling opption cause this module has been created on small scale.
 
## Module variables:
> [!IMPORTANT]
> Below are the module variables:
 - key_pair: mame of your keypair
 - cluster-description: It is your cluster description if needed, default value is "DevOps Project Cluster"
 - cce-node-type: Cluster nodes tyoe wether it's virtual machines or Bare metal servers default is "vm"
 - flavor_id: Cluster scale specifications, default values is "cce.s1.small"
 - cluster_k8s_version: K8S Version, default is "v1.25"
 - cluster-provisioning-type: Type of the cluster BMS or VMs, default is "cluster-provisioning-type"
 - network-type: Container Network type, possible values are:
    overlay_l2 - An overlay_l2 network built for containers by using Open vSwitch(OVS)
    underlay_ipvlan - An underlay_ipvlan network built for bare metal servers by using ipvlan.
    vpc-router - An vpc-router network built for containers by using ipvlan and custom VPC routes.
    default value is "vpc-router"
 - cluster-name: (Required) Name of your cluster
 - pool-name: (Required) Your node pool name
 - container-network: container network segment default is "172.16.0.0/16"
 - auth-mode: Possible options are x509 and rbac default value is "rbac"
 - container-subnet-id: Subnet ID of the subnet you want the cluster to be provisioned in.
 - os-name: The pool nodes OS, default value is "EulerOS 2.9"
 - pool-nodes-number: Desired number of nodes in your CCE cluster, value should be a number and default is 2
 - node-flavor: Flavor of your pool nodes, default is "s3.large.4"
 - avail-zone: Availability zone for pool nodes, default value is "eu-west-0c"
 - node-rootvol-size: System disk, Should be a number and default value is "40"
 - node-datavol-size: Data Disk, Should be a number and default value is "200"
 - vol-type: Pool nodes' volumes types, default is "SAS"

 ## Module required provider & version:

- It uses terrafor version >= 0.13 and FlexibleEngineCloud/flexibleengine provider version >= 1.30.0

- Below is a sample configuration:

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