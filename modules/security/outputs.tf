output "ext_alb_sg_id" {
  value = aws_security_group.ext-alb-sg.id
}
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
output "nginx_sg_id" {
  value = aws_security_group.nginx-sg.id
}
output "int_alb_sg_id" {
  value = aws_security_group.int-alb-sg.id
}
output "webserver_sg_id" {
  value = aws_security_group.webserver-sg.id
}
output "datalayer_sg_id" {
  value = aws_security_group.datalayer-sg.id
}