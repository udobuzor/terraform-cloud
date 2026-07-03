output "ext_alb_dns_name" {
  value = aws_lb.ext-alb.dns_name
}
output "nginx_target_group_arn" {
  value = aws_lb_target_group.nginx-tgt.arn
}
output "wordpress_target_group_arn" {
  value = aws_lb_target_group.wordpress-tgt.arn
}
output "tooling_target_group_arn" {
  value = aws_lb_target_group.tooling-tgt.arn
}
output "ext_alb_zone_id" {
  value = aws_lb.ext-alb.zone_id
}
output "internal_alb_dns_name" {
  value = aws_lb.ialb.dns_name
}