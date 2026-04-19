module "vpc" {
  source = "./modules/vpc"

  project_name              = var.project_name
  vpc_cidr                  = var.vpc_cidr
  az_a                      = var.az_a
  az_b                      = var.az_b
  public_subnet_a_cidr      = var.public_subnet_a_cidr
  public_subnet_b_cidr      = var.public_subnet_b_cidr
  private_app_subnet_a_cidr = var.private_app_subnet_a_cidr
  private_app_subnet_b_cidr = var.private_app_subnet_b_cidr
}

module "alb" {
  source = "./modules/alb"

  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  app_port          = var.app_port
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "ecs" {
  source = "./modules/ecs"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  target_group_arn       = module.alb.target_group_arn
  alb_security_group_id  = module.alb.alb_security_group_id
  ecr_repository_url     = module.ecr.repository_url
  app_port               = var.app_port
  container_image_tag    = var.container_image_tag
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    LoadBalancer = module.alb.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}