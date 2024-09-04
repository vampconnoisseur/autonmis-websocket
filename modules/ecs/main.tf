# Create ECS service
resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = var.ecs_cluster_name
  task_definition = var.task_definition
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.alb_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "flask-server"
    container_port   = 5000
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

# Creating a target group
resource "aws_lb_target_group" "tg" {
  name        = "ecs-target-group"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Attach the target group to the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = var.alb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}