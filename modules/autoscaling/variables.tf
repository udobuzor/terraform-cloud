variable "ami" {}
variable "keypair" {}
variable "bastion_sg_id" {}
variable "nginx_sg_id" {}
variable "webserver_sg_id" {}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "nginx_target_group_arn" {}
variable "wordpress_target_group_arn" {}
variable "tooling_target_group_arn" {}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "azs" {
  type = list(string)
}