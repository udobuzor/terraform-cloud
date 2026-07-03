module "VPC" {
  source = "./modules/VPC"

  region                              = var.region
  vpc_cidr                            = var.vpc_cidr
  enable_dns_support                  = var.enable_dns_support
  preferred_number_of_public_subnets  = var.preferred_number_of_public_subnets
  preferred_number_of_private_subnets = var.preferred_number_of_private_subnets
  name                                = var.name
  tags                                = var.tags
}

module "security" {
  source = "./modules/security"

  vpc_id = module.VPC.vpc_id
  tags   = var.tags
}

module "ALB" {
  source = "./modules/ALB"

  vpc_id          = module.VPC.vpc_id
  public_subnets  = module.VPC.public_subnets
  private_subnets = module.VPC.private_subnets
  ext_alb_sg_id   = module.security.ext_alb_sg_id
  int_alb_sg_id   = module.security.int_alb_sg_id
  certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
  tags            = var.tags
}

module "autoscaling" {
  source = "./modules/autoscaling"

  ami                        = var.ami
  keypair                    = var.keypair
  bastion_sg_id              = module.security.bastion_sg_id
  nginx_sg_id                = module.security.nginx_sg_id
  webserver_sg_id            = module.security.webserver_sg_id
  public_subnets             = module.VPC.public_subnets
  private_subnets            = module.VPC.private_subnets
  nginx_target_group_arn     = module.ALB.nginx_target_group_arn
  wordpress_target_group_arn = module.ALB.wordpress_target_group_arn
  tooling_target_group_arn   = module.ALB.tooling_target_group_arn
  azs                        = data.aws_availability_zones.available.names
  tags                       = var.tags
}

module "EFS" {
  source = "./modules/EFS"

  account_no      = var.account_no
  private_subnets = module.VPC.private_subnets
  datalayer_sg_id = module.security.datalayer_sg_id
  tags            = var.tags
}

module "RDS" {
  source = "./modules/RDS"

  private_subnets = module.VPC.private_subnets
  datalayer_sg_id = module.security.datalayer_sg_id
  master_username = var.master_username
  master_password = var.master_password
  tags            = var.tags
}