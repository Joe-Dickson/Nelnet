module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "lambda-in-vpc"
  description   = "My awesome lambda function"
  handler       = "handler.hello"
  runtime       = "python3.8"

  source_path = "./mylambda"

  vpc_subnet_ids         = module.vpc.intra_subnets
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  attach_network_policy  = true
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-lambda"
  cidr = "10.10.0.0/16"

  azs           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  intra_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  # Add public_subnets and NAT Gateway to allow access to internet from Lambda
  # public_subnets  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  # enable_nat_gateway = true
}