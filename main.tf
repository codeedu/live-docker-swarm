terraform {
    required_version = ">=0.13.1"
    required_providers {
      aws = ">=3.54.0"
      local = ">=2.1.0"
    }
    backend "s3" {
      bucket = "myfcbucket"
      key    = "terraform.tfstate"
      region = "us-east-1"
    }
}

provider "aws" {
  region = "us-east-2"
}

module "new-vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

resource "aws_security_group" "sg" {
  vpc_id = module.new-vpc.vpc_id
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
  }
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      prefix_list_ids = []
  }
  tags = {
      Name = "${var.prefix}-sg"
  }
}

module "ec2_instance_manager" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "manager"
  ami                    = "ami-00399ec92321828f5"
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = module.new-vpc.subnet_ids[0]

}

module "ec2_instance_manager_nodes"{
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(var.instance_manager_nodes)

  name = "${each.key}"

  ami                    = "ami-00399ec92321828f5"
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = module.new-vpc.subnet_ids[0]

}


module "ec2_instance_worker_nodes" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(var.instances_workers)

  name = "${each.key}"

  ami                    = "ami-00399ec92321828f5"
  instance_type          = var.instance_type
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = module.new-vpc.subnet_ids[0]

}
