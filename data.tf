data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "al2023-ami-ecs-hvm-2023.*-kernel-6.1-x86_64"
  owners      = ["amazon"]
}

data "aws_ecr_repository" "ecr_repository" {
  name = var.ecr_repository_name
}
