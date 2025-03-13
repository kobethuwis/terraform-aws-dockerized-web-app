# Dockerized Web App Public Deployment

This example demonstrates how to deploy a Dockerized web application using both private subnets for the application and public subnets for the load balancer. This setup allows your application to be publicly accessible while keeping the application instances secure. The EC2 instances/containers can thus only be accessed publicly via the ALB, according to the specified listeners & listener rules.

## Configuration

To deploy this example, make sure you pass the private subnet ids to the `app_subnet_ids` input parameter nd the public subnet ids to the `lb_subnet_id` input. 

```hcl
module "dockerized-web-app" {
  source               = "."
  region               = "eu-west-1"
  ec2_key_name         = "my-aws-key-pair"
  ssl_certificate_arn  = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids       = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids        = ["subnet-public-1", "subnet-public-2"]
  vpc_id               = "my-vpc"
  logs_bucket_id       = "my-logs-bucket"
  cidr_blocks          = "10.0.0.0/24"
  container_ports      = [8080]
  ecr_repository_name  = "my-ecr-repo"
  full_name            = "my-dockerized-web-app"
  docker_image_tag     = "latest"
}
```

Your ALB will be deployed in a public subnet, but you will still have to add a security group rule that allows incoming connections coming from ranges outside of the internal CIDR-block.