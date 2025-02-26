# terraform-aws-dockerized-web-app

Terraform module for deploying a Dockerized web application on AWS with ECS, ALB and EC2.

## Description

This Terraform module helps you set up and manage the infrastructure required to host a Dockerized web application on AWS. It provisions resources such as an ECS cluster, EC2 instances and an Application Load Balancer (ALB) to ensure your application is highly available and scalable.

The module supports both public facing and private facing deployments of the ALB (see examples).

## Features

- **HTTPS-terminated Load Balancing**: Automatically terminate incoming requests using an SSL certificate, without making changes to your base application.
- **Infrastructure Provisioning**: Use Terraform to define and provision the infrastructure required for your web application.
- **CI/CD Integration**: Integrate with GitHub Actions to automate the deployment process, including building Docker images and deploying them to different environments.
- **AWS Services**: Leverage AWS services like ECS, EC2, ECR and ELB to host and manage your web application.
- **Docker Support**: Build and deploy Docker images for your web application.
- **Health Checker**: ECS does a basic health check on /health endpoint to determine if the containers are actually running.

## Diagram

![dockerized-web-app-diagram](https://raw.githubusercontent.com/kobethuwis/terraform-aws-dockerized-web-app/refs/heads/main/dockerized-web-app-diagram.png)

## Prerequisites

- An AWS VPC with configured subnets.
- A valid AWS ACM Certificate.
- Working AWS EC2 Key Pair.
- AWS S3 Bucket for storing logs.
- Docker image (with tag latest), available on an AWS ECR repository.

## Usage

Initialize the module using the required input arguments.

```hcl
module "dockerized-web-app" {
  source              = "kobethuwis/dockerized-web-app/aws"
  version             = "2.2.3"
  source              = "."
  region              = "eu-west-1"
  ec2_key_name        = "my-aws-key-pair"
  ssl_certificate_arn = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids      = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids       = ["subnet-private-1", "subnet-private-2"]
  vpc_id              = "my-vpc"
  logs_bucket_id      = "my-logs-bucket"
  cidr_blocks         = "10.0.0.0/24"
  container_port      = 8080
  ecr_repository_name = "my-ecr-repo"
  full_name           = "my-dockerized-web-app"
  docker_image_tag    = "latest"
  tags                = "{my_tag = 'dockerized-web-app'}"
}
```

## License

This project is licensed under the MIT License.
