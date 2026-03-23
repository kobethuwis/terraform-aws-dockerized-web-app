terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.30.0"
    }
  }
}

resource "aws_security_group" "lb_security_group" {
  name_prefix = "${var.full_name}-lb-sg"
  vpc_id      = var.vpc_id

  tags = merge(
    { Name = "${var.full_name}-lb-sg" },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "lb_security_group_ingress_rule" {
  for_each          = toset(var.cidr_blocks)
  security_group_id = aws_security_group.lb_security_group.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS Client traffic"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "lb_security_group_egress_rule" {
  security_group_id = aws_security_group.lb_security_group.id
  ip_protocol       = "-1"
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "app_security_group" {
  name_prefix = "${var.full_name}-app-sg"
  vpc_id      = var.vpc_id

  tags = merge(
    { Name = "${var.full_name}-sg" },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "app_security_group_ingress_rule" {
  for_each = toset([for port in var.container_ports : tostring(port)])
  security_group_id             = aws_security_group.app_security_group.id
  from_port                     = tonumber(each.value)
  to_port                       = tonumber(each.value)
  ip_protocol                   = "tcp"
  description                   = "HTTP ALB traffic"
  referenced_security_group_id  = aws_security_group.lb_security_group.id
}

resource "aws_vpc_security_group_egress_rule" "app_security_group_egress_rule" {
  security_group_id = aws_security_group.app_security_group.id
  ip_protocol       = "-1"
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.full_name}-ecs-instance-profile"
  role = aws_iam_role.iam_role.name
}

resource "aws_iam_role" "iam_role" {
  name = "${var.full_name}-ecs-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["sts:AssumeRole"]
        Effect    = "Allow"
        Principal = { "Service" = "ec2.amazonaws.com" }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_managed_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "iam_policy" {
  name   = "${var.full_name}-ecs-iam-policy"
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_launch_template" "launch_template" {
  name                   = "${var.full_name}-launch-template"
  image_id               = data.aws_ami.ami.id
  key_name               = var.ec2_key_name
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.app_security_group.id]
  user_data              = base64encode(templatefile("${path.module}/user_data.sh", { cluster_name = var.full_name }))

  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      { "Name" = var.full_name },
      var.tags
    )
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.full_name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        s3_bucket_name = var.logs_bucket_id
        s3_key_prefix  = "${var.full_name}-ecs-cluster"
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = var.container_insights_config
  }

  tags = var.tags
}

resource "aws_lb_target_group" "lb_target_group" {
  for_each = toset([for port in var.container_ports : tostring(port)])
  name     = "${var.full_name}-tg-${each.value}"
  port     = each.value
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # only enable health checks when the ALB is deployed in a public subnet
  # a bug occurs when the ALB is deployed in a private subnet
  # which causes the health checks to fail
  health_check {
    enabled  = var.lb_subnet_ids != var.app_subnet_ids
    path     = "/"
    port     = tonumber(each.value)
    matcher  = "200,404"
    protocol = "HTTP"
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  desired_capacity      = 0
  max_size              = 4
  min_size              = 2
  vpc_zone_identifier   = var.app_subnet_ids
  protect_from_scale_in = true

  mixed_instances_policy {
    instances_distribution {
      spot_allocation_strategy = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template.id
        version            = aws_launch_template.launch_template.latest_version
      }
      override {
        instance_type = "t3a.nano"
      }
      override {
        instance_type = "t3.nano"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
      tag,
      mixed_instances_policy
    ]
  }
}

resource "aws_autoscaling_attachment" "lb_target_group_attachment" {
  for_each               = aws_lb_target_group.lb_target_group
  lb_target_group_arn    = each.value.arn
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${var.full_name}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.autoscaling_group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = var.full_name
  container_definitions = jsonencode([
    {
      name      = "${var.full_name}"
      image     = "${data.aws_ecr_repository.ecr_repository.repository_url}:${var.docker_image_tag}"
      cpu       = 2000
      memory    = 400
      essential = true
      portMappings = [
        for port in var.container_ports : {
          containerPort = port
          hostPort      = port
        }
      ]
      healthCheck = var.enable_container_health_checks ? {
        command  =  ["CMD-SHELL", var.health_check_command]
        startPeriod = 30
        } : null

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = var.full_name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "aws-logs-${var.full_name}"
        }
      }
    }
  ])
}

resource "aws_lb" "lb" {
  name               = "${var.full_name}-lb"
  internal           = var.lb_subnet_ids == var.app_subnet_ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = var.lb_subnet_ids

  access_logs {
    bucket  = var.logs_bucket_id
    prefix  = "${var.full_name}-lb/access-logs"
    enabled = true
  }

  connection_logs {
    prefix  = "${var.full_name}-lb/connection-logs"
    bucket  = var.logs_bucket_id
    enabled = true
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = values(aws_lb_target_group.lb_target_group)[0].arn
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.full_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.id
  desired_count   = 2

  load_balancer {
    target_group_arn = values(aws_lb_target_group.lb_target_group)[0].arn
    container_name   = var.full_name
    container_port   = var.container_ports[0]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      task_definition
    ]
  }
}
