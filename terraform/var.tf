variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "udproj1"
  type = string
}

variable "resource_group_name" {
  description = "The azure resource group name that contains the packer image"
  default = "udacity_proj_1"
  type = string
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "West Europe"
  type = string
}

variable "image_name" {
  description = "The name of the packer image"
  default = "udacity_proj_1_packer"
  type = string
}

variable "username" {
  description = "The user name"
  default = "ud123"
  type = string
}

variable "password" {
  description = "The password"
  default = "sdf234XX234021029!!"
  type = string
}

variable "vm_size" {
  description = "The size of the vm"
  default = "Standard_D2s_v3"
  type = string
}

variable "number_vm" {
  description = "The number of virtual machines"
  default = 3
  type = number
}