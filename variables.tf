variable "region" {
  default = "us-east-1"
}
variable "vpc_cidr" {
  default = "172.16.0.0/16"
}
variable "enable_dns_support" {
  default = "true"
}
variable "enable_dns_hostnames" {
  default = "true"
}
variable "enable_classiclink" {
  default = "false"
}
variable "enable_classiclink_dns_support" {
  default = "false"
}
variable "preferred_number_of_public_subnets" {
  default = null
}
variable "name" {
  type    = string
  default = "OddShare"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "preferred_number_of_private_subnets" {
  default = 4
}
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
variable "keypair" {
  type        = string
  description = "Key pair for the instances"
}
variable "account_no" {
  type        = string
  description = "AWS account number"
}
variable "master_username" {
  type        = string
  description = "RDS admin username"
}
variable "master_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
}


