provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "Website-dev-environment"
    }
  }
}
terraform {
  backend "s3" {
    bucket         = "terraform-state-600627315506-ap-south-1 "
    key            = "environments/{env}/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

module "networking" {
  source                = "../../modules/networking"
  region                = var.region
  vpc_cidr              = var.vpc_cidr
  vpc_name              = var.vpc_name
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_1_name = var.private_subnet_1_name
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_1_name  = var.public_subnet_1_name
  igw_name              = var.igw_name
  public_rt_name        = var.public_rt_name
  availability_zone     = var.availability_zone
  environment           = var.environment
}

module "compute" {
  source         = "../../modules/compute"
  vpc_id         = module.networking.vpc_id
  subnet_id      = module.networking.public_subnet_id
  sg_name        = var.sg_name
  sg_desc        = var.sg_desc
  sg_cidr_blocks = var.sg_cidr_blocks
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  disk_size      = var.disk_size
  instance_name  = var.instance_name
}
