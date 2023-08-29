#Create Security Group
resource "flexibleengine_networking_secgroup_v2" "project_sec_grp" {
  name        = var.sec_grp_name
  description = var.sg-description
}

# Create Security Group Rule to allow SSH traffic from public internet
resource "flexibleengine_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = flexibleengine_networking_secgroup_v2.project_sec_grp.id
}

# Create a Block Volume to be attached later to the VM
resource "flexibleengine_blockstorage_volume_v2" "jump_vol" {
  name = "${var.bastion-name}_Disk"
  size = var.bastion-disk-size
}

# Create an Elastic Cloud Server resource
resource "flexibleengine_compute_instance_v2" "JumpServerName" {
  name            = var.bastion-name
  image_name      = var.jump-image_name
  flavor_id       = var.jump-flavor
  key_pair        = var.key_pair
  security_groups = ["${flexibleengine_networking_secgroup_v2.project_sec_grp.id}"]
  network {
    uuid = var.bastion-subnet-id
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