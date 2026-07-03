variable "region" {}
variable "vpc_cidr" {}
variable "enable_dns_support" {}
variable "preferred_number_of_public_subnets" {}
variable "preferred_number_of_private_subnets" {}
variable "name" {}
variable "tags" {
  type    = map(string)
  default = {}
}