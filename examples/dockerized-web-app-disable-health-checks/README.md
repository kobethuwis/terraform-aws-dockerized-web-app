# Dockerized Web App Private Deployment

This example demonstrates how to deploy a Dockerized web application without using the suggested health checks. Might come in handy if you are not able to extend you base application code with a health check on /health.

## Configuration

To deploy this example, ensure you pass the 'disable_health_checks' param.

```hcl
module "dockerized-web-app" {
  source                = "."
  region                = "eu-west-1"
  ec2_key_name          = "my-aws-key-pair"
  ssl_certificate_arn   = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids        = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids         = ["subnet-private-1", "subnet-private-2"]
  vpc_id                = "my-vpc"
  logs_bucket_id        = "my-logs-bucket"
  cidr_blocks           = "10.0.0.0/24"
  container_port        = 8080
  ecr_repository_name   = "my-ecr-repo"
  full_name             = "my-dockerized-web-app"
  docker_image_tag      = "latest"
  disable_health_checks = true
}
```