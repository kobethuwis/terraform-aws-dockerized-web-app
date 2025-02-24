module "dockerized-web-app" {
  source              = "."
  region              = "eu-west-1"
  ec2_key_name        = "my-aws-key-pair"
  ssl_certificate_arn = "arn:aws:acm:eu-west-1:XXXXXXXXXX:certificate/XXXXXXXXXX"
  app_subnet_ids      = ["subnet-private-1", "subnet-private-2"]
  lb_subnet_ids       = ["subnet-public-1", "subnet-public-2"]
  vpc_id              = "my-vpc"
  logs_bucket_id      = "my-logs-bucket"
  cidr_blocks         = "10.0.0.0/24"
  container_port      = 8080
  ecr_repository_name = "my-ecr-repo"
  full_name           = "my-dockerized-web-app"
  docker_image_tag    = "latest"
}
