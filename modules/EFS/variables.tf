variable "account_no" {}
variable "private_subnets" {
  type = list(string)
}
variable "datalayer_sg_id" {}
variable "tags" {
  type    = map(string)
  default = {}
}