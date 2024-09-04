module "network" {
  source   = "./modules/network"
  vpc_id   = var.vpc_id
  subnets  = var.subnets
}

module "ecs" {
  source             = "./modules/ecs"
  ecs_cluster_name   = var.ecs_cluster_name
  task_definition    = var.task_definition
  subnets            = var.subnets
  vpc_id             = var.vpc_id
  alb_sg_id          = module.network.alb_sg_id
  alb_arn            = module.network.alb_arn 
}

module "autoscaling" {
  source           = "./modules/autoscaling"
  ecs_cluster_name = var.ecs_cluster_name
  ecs_service_name = module.ecs.ecs_service_name
}

module "monitoring" {
  source     = "./modules/monitoring"
  alb_arn    = module.network.alb_arn
  alb_suffix = module.network.alb_suffix
  region     = var.region
  username   = var.username
}

module "route53" {
  source       = "./modules/route53"
  hosted_zone_id = var.hosted_zone_id
  subdomain    = var.subdomain
  alb_dns_name = module.network.alb_dns_name
}