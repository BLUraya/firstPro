variable "vpc_id" {
  description = "id of VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "list of private subnet ids"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "list of public subnet ids"
  type        = list(string)
}

variable "ec2_instance_type" {
  description = "the instance type for ec2"
  type        = string
  default     = "t3.small"
}