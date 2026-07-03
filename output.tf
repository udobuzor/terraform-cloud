output "alb_dns_name" {
  value = module.ALB.ext_alb_dns_name
}
output "alb_target_group_arn" {
  value = module.ALB.nginx_target_group_arn
}
output "rds_endpoint" {
  value = module.RDS.rds_endpoint
}
output "efs_id" {
  value = module.EFS.efs_id
}
output "internal_alb_dns" {
  value = module.ALB.internal_alb_dns_name
}

