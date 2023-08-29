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

# Create jump server from fe-basion module
module "basion-server" {
  source = "./modules/fe-bastion"
  bastion-name = var.bastion-name
  bastion-disk-size = var.bastion-disk-size
  sec_grp_name = "${var.bastion-name}_SG"
  jump-image_name = var.jump-image_name
  jump-flavor = var.bastion-flavor
  key_pair = var.key_pair
  bastion-subnet-id = flexibleengine_vpc_subnet_v1.sub1.id
}

# Create CCE Cluter using fe-cce-cluster module
module "K8s-cluster" {
  source = "./modules/fe-cce-cluster"
  vpc-id = flexibleengine_vpc_v1.projectVPC.id
  key_pair = var.key_pair
  cluster-provisioning-type = "VirtualMachine"
  cce-node-type = "vm"
  flavor_id = var.flavor_id
  cluster_k8s_version = "v1.25"
  network-type = var.network-type
  cluster-name = var.cluster-name
  pool-name = var.pool-name
  container-network = "172.16.0.0/16"
  auth-mode = "rbac"
  container-subnet-id = flexibleengine_vpc_subnet_v1.sub2.id
  os-name = "EulerOS 2.9"  
  pool-nodes-number = 2
  node-flavor = "s3.large.4"
  avail-zone = "eu-west-0c"
  node-rootvol-size = 40
  node-datavol-size = 200
  vol-type = "SAS" 
}
