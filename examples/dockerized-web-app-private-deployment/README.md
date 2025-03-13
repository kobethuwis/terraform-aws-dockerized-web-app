# Dockerized Web App Private Deployment

This example demonstrates how to deploy a Dockerized web application using private subnets for both the application and load balancer. This setup ensures that your application is not directly accessible from the internet and your ALB is deployed internally. In turn, you could use a AWS Route53 record to resolve the ALB DNS name internally.

## Configuration

To deploy this example, ensure you pass the private subnet ids to both the `app_subnet_ids` & `lb_subnet_id` inputs. If the 2 vars are the same, Terraform will provision an internal ALB.

```hcl
module "dockerized-web-app" {
  source               = "."
  region               = "eu-west-1"
  ec2_key_name         = "my-aws-key-pair"
  ssl_certificate_arn  = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids       = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids        = ["subnet-private-1", "subnet-private-2"]
  vpc_id               = "my-vpc"
  logs_bucket_id       = "my-logs-bucket"
  cidr_blocks          = "10.0.0.0/24"
  container_ports      = [8080]
  ecr_repository_name  = "my-ecr-repo"
  full_name            = "my-dockerized-web-app"
  docker_image_tag     = "latest"
}
```