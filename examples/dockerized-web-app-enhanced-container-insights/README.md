# Dockerized Web App with Enhanced Container Insights

This example demonstrates how to set up the module with enhanced container insights. If your would like to monitor per-task resource usage and monitor the containers themselves, follow the instructions below.

## Configuration

To deploy this example, ensure you update the container_insights_config variable. Container health insights are set accordingly.

```hcl
module "dockerized-web-app" {
  source                      = "."
  region                      = "eu-west-1"
  ec2_key_name                = "my-aws-key-pair"
  ssl_certificate_arn         = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids              = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids               = ["subnet-private-1", "subnet-private-2"]
  vpc_id                      = "my-vpc"
  logs_bucket_id              = "my-logs-bucket"
  cidr_blocks                 = "10.0.0.0/24"
  container_ports             = [8080, 9090]
  ecr_repository_name         = "my-ecr-repo"
  full_name                   = "my-dockerized-web-app"
  docker_image_tag            = "latest"
  container_insights_config   = "enhanced"
}
```