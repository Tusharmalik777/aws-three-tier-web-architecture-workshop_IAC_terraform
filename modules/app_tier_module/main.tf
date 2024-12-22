
#Here I will try to create App tier instance and try to create AMI from it



resource "aws_iam_policy" "s3_rds_policy" {
  name        = "s3_rds_access_policy"
  description = "Allow access to S3 and RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # S3 Access - Allows full access to all S3 resources
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "*"
      },
      # RDS Access - Allows full access to all RDS resources
      {
        Action   = "rds:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "Threetierprojectrole" {
  name = "Threetierprojectrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}
# Attach custom S3 and RDS policy to the role
resource "aws_iam_role_policy_attachment" "s3_rds_policy_attachment" {
  role       = aws_iam_role.Threetierprojectrole.name
  policy_arn = aws_iam_policy.s3_rds_policy.arn
}

# Attach AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.Threetierprojectrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



resource "aws_iam_instance_profile" "threetierprojectroleprofile" {
  name = "threetierprojectroleprofile"
  role = "Threetierprojectrole"
}



data "template_file" "user_data" {
  template = file("App_tier_script.sh.tpl")

  vars = {
    RDS_endpoint       = var.RDS_endpoint
    app_tier_subnet_id = var.app_tier_subnet_id
  }
}
resource "aws_instance" "App_tier_instance" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "3tierprojectkey"
  subnet_id              = var.app_tier_subnet_id //referncing output variable from VPC module
  vpc_security_group_ids = [var.app_tier_security_group_id] //referncing output variable from module
  iam_instance_profile   = aws_iam_instance_profile.threetierprojectroleprofile.name
  user_data              = data.template_file.user_data.rendered

  tags = {
    name = "App_tier_instance"
  }

}

