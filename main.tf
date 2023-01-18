
#################################################################################
# CONFIGURE BACKEND
#################################################################################

terraform {
  required_version = ">=1.1.0" #version 

  #     backend "s3" { 
  # bucket                  = "3-tier-architecture-implementation"
  # key                     = "path/env/jenkins-infra-deployment-of-terraform"
  # region                  = "us-east-1"
  # dynamodb_table          = "terraform-lock"
  # encrypt                 = true
  #     }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

#################################################################################
# PROVIDERS BLOCK
#################################################################################
provider "aws" {
  region = "us-east-1"
}


#################################################################################
# LOCAL BLOCK
#################################################################################
locals {
  vpc_id = module.vpc.vpc_id
}



#################################################################################
# DATA SOURCE BLOCK
#################################################################################
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5. 10-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


#################################################################################
# RESOURCE BLOCK
#################################################################################
resource "aws_instance" "jenkins-server" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t3.large"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  user_data = file("${path.module}/templates/jenkins.sh") #installation jenkins

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_instance" "sonarqube-server" {
  ami                    = data.aws_ami.ami.id
  instance_type          = "t3.large"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  user_data              = file("${path.module}/templates/sonarqube.sh")

  tags = {
    Name = "sonarqube-server"
  }
}


#################################################################################
# MODULES BLOCK
#################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.component_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}