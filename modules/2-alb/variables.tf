
variable "vpc_id" {
  description = "the VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "list of public subnets for the ALB"
  type        = list(string)
}

variable "gitlab_instance_id" {
  description = "the EC2 instance ID for GitLab"
  type        = string
}

variable "jenkins_instance_id" {
  description = "the EC2 instance ID for Jenkins"
  type        = string
}

variable "eks_asg_name" {
  description = "the Auto Scaling Group name of the EKS Node Group"
  type        = string
}
