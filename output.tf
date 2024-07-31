output "tls_private_key" {
  value     = tls_private_key.secureadmin_ssh.private_key_pem
  sensitive = true
}

output "pips" {
  value = [ for pip in azurerm_public_ip.public_ip: pip.ip_address]
}

output "names" {
  value = [ for pip in azurerm_public_ip.public_ip: pip.name]
}

#terraform output -raw tls_private_key > secureadmin_id_rsa

# output "test" {
#   value = {for index, instance in var.instance_set: instance.name => instance}
# }

# locals {
#   names_list = [for key, obj in var.instance_set : obj.vnet]
#   unique_names_set = toset(local.names_list)

#   object = [toset([for instance in var.instance_set: {"vnet": instance.vnet, "cidr": instance.cidr, "region": instance.region}])]
# }

# # output "test" {
# #   value = {for instance in var.instance_set: instance.name => instance }
# # }

# # output "tes1t" {
# #   value = toset({for instance in var.instance_set: instance.vnet => instance})
# # }

# output "asd" {
#   value = local.object
# }

