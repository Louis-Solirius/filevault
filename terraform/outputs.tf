output "bastion_host_name" {
  description = "Name of the Bastion Host"
  value       = azurerm_bastion_host.bastion.name
}

output "bastion_host_ip" {
  description = "Public IP of the Bastion Host"
  value       = azurerm_public_ip.bastion_public_ip.ip_address
}