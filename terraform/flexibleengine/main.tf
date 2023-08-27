#Define Variables
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

variable "vpc_name" {
  description = "Name for the VPC you wnat to create"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
}

variable "first_subnet_name" {
  description = "Name of the subnet you wnat to create"
}

variable "second_subnet_name" {
  description = "Name of the subnet you wnat to create"
}

variable "first_subnet_cidr" {
  description = "First Subnet CIDR Block"
}

variable "second_subnet_cidr" {
  description = "Second Subnet CIDR Block"
}

variable "first_subnet_gw_IP" {
  description = "First Subnet GW IP"
}

variable "second_subnet_gw_IP" {
  description = "Second Subnet GW IP"
}

variable "key_pair" {
  description = "KeyPair name"
}

variable "nat_gw" {
  description = "NAT Gateway Name"
}

variable "sec_grp_name" {
  description = "Security Group Name"
}
#Create VPC
resource "flexibleengine_vpc_v1" "projectVPC" {
  name = var.vpc_name
  cidr = var.vpc_cidr
}


# Create First Subnet
resource "flexibleengine_vpc_subnet_v1" "sub1" {
  name       = var.first_subnet_name
  cidr       = var.first_subnet_cidr
  gateway_ip = var.first_subnet_gw_IP
  vpc_id     = flexibleengine_vpc_v1.projectVPC.id
  primary_dns = "100.125.0.41"
  secondary_dns = "100.126.0.41"
}

# Create Second Subnet
resource "flexibleengine_vpc_subnet_v1" "sub2" {
  name       = var.second_subnet_name
  cidr       = var.second_subnet_cidr
  gateway_ip = var.second_subnet_gw_IP
  vpc_id     = flexibleengine_vpc_v1.projectVPC.id
  primary_dns = "100.125.0.41"
  secondary_dns = "100.126.0.41"
}

#Create Security Group
resource "flexibleengine_networking_secgroup_v2" "project_sec_grp" {
  name        = var.sec_grp_name
  description = "Project Security Group"
}

# Create Security Group Rule
resource "flexibleengine_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = flexibleengine_networking_secgroup_v2.project_sec_grp.id
}
#Create Floating IP For NGW
resource "flexibleengine_vpc_eip" "ngw_float_ip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name = "${var.nat_gw}_IP"
    size = 8
    share_type = "PER"
    charge_mode = "traffic"
  }
}

#Create NGW
resource "flexibleengine_nat_gateway_v2" "nat_gateway" {
  name        = var.nat_gw
  description = "Project NGW"
  spec        = "1"
  vpc_id      = flexibleengine_vpc_v1.projectVPC.id
  subnet_id   = flexibleengine_vpc_subnet_v1.sub2.id
}

# Create SNAT Rule
resource "flexibleengine_nat_snat_rule_v2" "snat_1" {
  nat_gateway_id = flexibleengine_nat_gateway_v2.nat_gateway.id
  floating_ip_id = flexibleengine_vpc_eip.ngw_float_ip.id
  subnet_id      = flexibleengine_vpc_subnet_v1.sub2.id
}

# Sleep to make sure subnets are created
resource "time_sleep" "wait_for_subnets_fully_finctioning" {
  create_duration = "120s"

        depends_on = [
     flexibleengine_vpc_v1.projectVPC ,
     flexibleengine_vpc_subnet_v1.sub1 ,
     flexibleengine_vpc_subnet_v1.sub2 
       ]
}

# Get list of subnets ids
data "flexibleengine_vpc_subnet_ids_v1" "subnet_ids" {
  depends_on = [ time_sleep.wait_for_subnets_fully_finctioning ]
  vpc_id = flexibleengine_vpc_v1.projectVPC.id
}

#Create Route Table
resource "flexibleengine_vpc_route_table" "route_table" {
    depends_on = [
     data.flexibleengine_vpc_subnet_ids_v1.subnet_ids
    ]
  name        = "${var.vpc_name}_RT"
  vpc_id      = flexibleengine_vpc_v1.projectVPC.id
  subnets = data.flexibleengine_vpc_subnet_ids_v1.subnet_ids.ids
  description = "Project Route Table"
  # timeouts {
  #   create = "4m"
  #}
  route {
    destination = "0.0.0.0/0"
    type        = "nat"
    nexthop     = flexibleengine_nat_gateway_v2.nat_gateway.id
  }
  
}
# Create a Block Volume to be attached later to the VM
resource "flexibleengine_blockstorage_volume_v2" "jump_vol" {
  name = "${var.bastion-name}_Disk"
  size = var.bastion-disk-size
}
# Create an Elastic Cloud Server resource
resource "flexibleengine_compute_instance_v2" "JumpServerName" {
  name            = var.bastion-name
  image_name      = "OBS CentOS 7.9"
  flavor_id       = "s3.large.2"
  key_pair        = var.key_pair
  security_groups = ["${flexibleengine_networking_secgroup_v2.project_sec_grp.id}"]
  network {
    uuid = flexibleengine_vpc_subnet_v1.sub1.id
  }
}
# Attach the created volume to the created instance
resource "flexibleengine_compute_volume_attach_v2" "attached" {
  instance_id = flexibleengine_compute_instance_v2.JumpServerName.id
  volume_id   = flexibleengine_blockstorage_volume_v2.jump_vol.id
}

# Create Floating IP
resource "flexibleengine_vpc_eip" "JumpServerIP" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name = var.bastion-name
    size = 5
    share_type = "PER"
    charge_mode = "traffic"
  }
}

resource "flexibleengine_compute_floatingip_associate_v2" "floatingIP" {
  floating_ip = flexibleengine_vpc_eip.JumpServerIP.publicip.0.ip_address
  instance_id = flexibleengine_compute_instance_v2.JumpServerName.id
}

# Create CCE Cluster
variable "flavor_id" { 
  description = "Flavor of the (Required) Cluster specifications. Changing this parameter will create a new cluster resource."
}

variable "network-type" {
  description = "Container network type"
}

variable "cluster-name" {}

variable "pool-name" {}

resource "flexibleengine_cce_cluster_v3" "project-cluster" {
  depends_on = [
     flexibleengine_vpc_route_table.route_table
    ]
  name                   = var.cluster-name
  cluster_type           = "VirtualMachine"
  cluster_version        = "v1.25"
  container_network_cidr = "172.16.0.0/16"
  authentication_mode    = "rbac"
  description            = "DevOps Project Cluster"
  flavor_id              = var.flavor_id
  vpc_id                 = flexibleengine_vpc_v1.projectVPC.id
  subnet_id              = flexibleengine_vpc_subnet_v1.sub2.id
  container_network_type = var.network-type
  # masters {
  #       availability_zone = "eu-west-0c"
#    }

}

# Create CCE Cluster Node Pool
resource "flexibleengine_cce_node_pool_v3" "node_pool" {
  cluster_id               = flexibleengine_cce_cluster_v3.project-cluster.id
  name                     = var.pool-name
  os                       = "EulerOS 2.9"
  initial_node_count       = 2
  flavor_id                = "s3.large.4"
  availability_zone        = "eu-west-0c"
  key_pair                 = var.key_pair
  scale_enable             = false
  # min_node_count           = 1
  # max_node_count           = 10
  # scale_down_cooldown_time = 100
  # priority                 = 1
  type                     = "vm"

  root_volume {
    size       = 40
    volumetype = "SAS"
  }
  data_volumes {
    size       = 200
    volumetype = "SAS"
  }
}

output "Floating_IP" {
  description = "Jump Server floating IP"
  value =  flexibleengine_vpc_eip.JumpServerIP.publicip.0.ip_address
}

output "Server_ID" {
  description = "Jump Server ID"
  value = flexibleengine_compute_instance_v2.JumpServerName.id
}

output "DiskSize" {
  description = "Jump Server EVS Disk Size"
  value = flexibleengine_blockstorage_volume_v2.jump_vol.bastion-disk-size
}