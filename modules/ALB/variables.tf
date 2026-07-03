variable "vpc_id" {}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "ext_alb_sg_id" {}
variable "int_alb_sg_id" {}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "certificate_arn" {}