# Create CCE Cluster
resource "flexibleengine_cce_cluster_v3" "project-cluster" {
  name                   = var.cluster-name
  cluster_type           = var.cluster-provisioning-type
  cluster_version        = var.cluster_k8s_version
  container_network_cidr = var.container-network
  authentication_mode    = var.auth-mode
  description            = var.cluster-description
  flavor_id              = var.flavor_id
  vpc_id                 = var.vpc-id
  subnet_id              = var.container-subnet-id
  container_network_type = var.network-type
  # masters {
  #       availability_zone = "eu-west-0c"
#    }

}

# Create CCE Cluster Node Pool
resource "flexibleengine_cce_node_pool_v3" "node_pool" {
  cluster_id               = flexibleengine_cce_cluster_v3.project-cluster.id
  name                     = var.pool-name
  os                       = var.os-name
  initial_node_count       = var.pool-nodes-number
  flavor_id                = var.node-flavor
  availability_zone        = var.avail-zone
  key_pair                 = var.key_pair
  scale_enable             = false
  # min_node_count           = 1
  # max_node_count           = 10
  # scale_down_cooldown_time = 100
  # priority                 = 1
  type                     = var.cce-node-type

  root_volume {
    size       = var.node-rootvol-size
    volumetype = var.vol-type
  }
  data_volumes {
    size       = var.node-datavol-size
    volumetype = "SAS"
  }
}
