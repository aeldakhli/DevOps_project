output "bastion" {
 value =  flexibleengine_compute_instance_v2.JumpServerName
}
output "Floating_IP" {
   description = "Jump Server floating IP"
   value =  flexibleengine_vpc_eip.JumpServerIP.publicip.0.ip_address
 }

# output "Server_ID" {
#   description = "Jump Server ID"
#   value = flexibleengine_compute_instance_v2.JumpServerName.id
# }