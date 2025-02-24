variable "full_name" {
  description = "Generic name used for resources related to the application"
}

variable "region" {
  description = "AWS region"
}

variable "ec2_key_name" {
  description = "Name of the key pair to use for connection with the EC2 instances"
}

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "app_subnet_ids" {
  description = "IDs of the subnets for the EC2 instances"
}

variable "lb_subnet_ids" {
  description = "IDs of the subnets for the load balancer"
}

variable "container_port" {
  description = "Port which is exposed in the container"
}

variable "ssl_certificate_arn" {
  description = "ARN of the ACM SSL certificate for the load balancer"
}

variable "cidr_blocks" {
  description = "CIDR blocks which should have access to the load balancer and application"
}

variable "logs_bucket_id" {
  description = "ID of the bucket for load balancer logs"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
}

variable "docker_image_tag" {
  description = "Tag of the docker image"
}
