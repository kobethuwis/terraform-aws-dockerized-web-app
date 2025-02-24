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

## Diagram

![dockerized-web-app-diagram](https://raw.githubusercontent.com/kobethuwis/terraform-aws-dockerized-web-app/edd8948b48bb47308130f43dacc6a7bd5c4fb3af/dockerized-web-app-diagram.png)

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
  source  = "kobethuwis/dockerized-web-app/aws"
  version = "2.1.2"
  ...
}
```

## License

This project is licensed under the MIT License.
