variable "bastion_ami" {
  type        = string
  description = "AMI ID for bastion host"
}

variable "nginx_ami" {
  type        = string
  description = "AMI ID for nginx reverse proxy"
}

variable "wordpress_ami" {
  type        = string
  description = "AMI ID for wordpress servers"
}

variable "tooling_ami" {
  type        = string
  description = "AMI ID for tooling servers"
}
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