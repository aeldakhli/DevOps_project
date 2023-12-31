bastion-name = "BastionServer"
bastion-disk-size = 100
jump-image_name = "OBS CentOS 7.9"
bastion-flavor = "s3.large.2"
vpc_name = "Dakhli_Project_VPC"
vpc_cidr = "10.0.0.0/8"
first_subnet_name = "SubnetOne"
second_subnet_name = "SubnetTwo"
sec_grp_name = "ProjectSecGrp"
first_subnet_cidr = "10.0.0.0/24"
second_subnet_cidr = "10.0.1.0/24"
first_subnet_gw_IP = "10.0.0.1"
second_subnet_gw_IP = "10.0.1.1"
nat_gw = "NGW"
cluster-name = "devops-project-cluster"
flavor_id = "cce.s2.small"
network-type = "vpc-router"
pool-name = "project-pool"