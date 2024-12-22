variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ami_id_app_tier" {
  description = "AMI ID for EC2 instances"
  type        = string
  default = "ami-0195204d5dce06d99"
}

variable "instance_type_app_tier" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}