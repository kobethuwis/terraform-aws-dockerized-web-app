# terraform-aws-dockerized-web-app

Terraform module for deploying a Dockerized web application on AWS with ECS, ALB, and EC2.

## Description

This Terraform module helps you set up and manage the infrastructure required to host a Dockerized web application on AWS. It provisions resources such as an ECS cluster, EC2 instances and an Application Load Balancer (ALB) to ensure your application is highly available and scalable.

The module supports both public facing and private facing deployments of the ALB (see examples).

## Features

- **Load Balancing**: Automatically distribute incoming application traffic across multiple targets, such as EC2 instances, using ALB.
- **Infrastructure Provisioning**: Use Terraform to define and provision the infrastructure required for your web application.
- **CI/CD Integration**: Integrate with GitHub Actions to automate the deployment process, including building Docker images and deploying them to different environments.
- **AWS Services**: Leverage AWS services like ECS, EC2, ECR, and ELB to host and manage your web application.
- **Docker Support**: Build and deploy Docker images for your web application.

## License

This project is licensed under the MIT License.
