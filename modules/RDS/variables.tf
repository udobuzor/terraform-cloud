variable "private_subnets" {
  type = list(string)
}
variable "datalayer_sg_id" {}
variable "master_username" {}
variable "master_password" {
  sensitive = true
}
variable "tags" {
  type    = map(string)
  default = {}
}