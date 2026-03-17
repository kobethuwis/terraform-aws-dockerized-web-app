# Dockerized Web App with Multiple Container Ports

This example demonstrates how to set up the module for multiple container ports. If your application contains multiple endpoints or your docker image exposes multiple, you should expose them through the AWS ALB accordingly.

## Configuration

To deploy this example, ensure you pass a second (or multiple) container port. The security group rules, autscaling target groups and attachments are made accordingly.

```hcl
module "dockerized-web-app" {
  source                 = "."
  region                 = "eu-west-1"
  ec2_key_name           = "my-aws-key-pair"
  ssl_certificate_arn    = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids         = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids          = ["subnet-private-1", "subnet-private-2"]
  vpc_id                 = "my-vpc"
  logs_bucket_id         = "my-logs-bucket"
  cidr_blocks            = "10.0.0.0/24"
  container_ports        = [8080, 9090]
  ecr_repository_name    = "my-ecr-repo"
  full_name              = "my-dockerized-web-app"
  docker_image_tag       = "latest"
}
```

Make a custom resource for accepting incoming connections on your custom ports on the load balancer by provisioning an ALB listener.

```hcl
resource "aws_lb_listener" lb_listener" {
  depends_on        = [module.dockerized_web_app]
  load_balancer_arn = module.dockerized_web_app.load_balancer.arn
  port              = 9090
  protocol          = "HTTPS"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = module.dockerized_web_app.target_group[1].arn
  }
}
```