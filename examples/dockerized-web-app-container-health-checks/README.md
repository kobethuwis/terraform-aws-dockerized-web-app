# Dockerized Web App with Container Health Checks

This example demonstrates how to deploy a Dockerized web application while using specific container health checks. Might come in handy if you want to truly check if your application is available on a specific endpoint (or /health). Th e

## Configuration

To deploy this example, ensure you pass the `enable_container_health_checks` and `health_check_command` variables. Setting these accordingly allows you to define insightful health checks tailored to your containerized application.

```hcl
module "dockerized-web-app" {
  source                            = "."
  region                            = "eu-west-1"
  ec2_key_name                      = "my-aws-key-pair"
  ssl_certificate_arn               = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids                    = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids                     = ["subnet-private-1", "subnet-private-2"]
  vpc_id                            = "my-vpc"
  logs_bucket_id                    = "my-logs-bucket"
  cidr_blocks                       = "10.0.0.0/24"
  container_ports                   = [8080]
  ecr_repository_name               = "my-ecr-repo"
  full_name                         = "my-dockerized-web-app"
  docker_image_tag                  = "latest"
  enable_container_health_checks    = true
  health_check_command              = "curl -f http://localhost:8080/health || exit 1"

}
```