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