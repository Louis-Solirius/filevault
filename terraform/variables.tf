variable "location" {
  type    = string
  default = "uksouth"
}

variable "vm_admin_username" {
  type    = string
  default = "louisadmin"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "ed25519_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqBqq73iIj6OTtZ5ESi3Igz0cy+MkGdvzvw5wNyDZK6 louisware@SoliriusC93Y0Q3GNW"
}

variable "ed25519_2_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzpGAbyHYWeexyISdlHUUEoIMtguIY/ENQcEo2edqZJ louisware@SoliriusC93Y0Q3GNW"
}
