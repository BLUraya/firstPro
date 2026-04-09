terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

#  aws Provider
provider "aws" {
  region = "us-east-1"
}

# ------- modules

module "vpc" {
  source = "./modules/0-vpc"
}

module "infra" {
  source             = "./modules/1-infrastructure"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "alb" {
  source              = "./modules/2-alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  gitlab_instance_id  = module.infra.gitlab_instance_id
  jenkins_instance_id = module.infra.jenkins_instance_id
  eks_asg_name        = module.infra.eks_node_group_asg_name
}

#--- module 3 for nodePort

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.infra.eks_cluster_name
}

# הגדרת הפרובידר של קוברנטיס
provider "kubernetes" {
  host                   = module.infra.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.infra.eks_cluster_ca)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

# קריאה למודול השלישי
module "k8s_resources" {
  source = "./modules/3-k8s-resources"

  host                   = module.infra.eks_cluster_endpoint
  cluster_ca_certificate = module.infra.eks_cluster_ca
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}
