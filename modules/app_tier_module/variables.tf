variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"  # Optional default value
}

variable "app_tier_subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed"
  type        = string
}

variable "app_tier_security_group_id" {
  description = "security group ID for the EC2 instance"
  type        = string
}

variable "RDS_endpoint" {
  description = "RDS endpoint generated in VPC module"
  type = string
}
