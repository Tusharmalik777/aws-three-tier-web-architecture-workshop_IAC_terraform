module "My_module_for_basic_infracreation" {
  source = "./My_module_for_basic_infracreation"
}

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
    RDS_endpoint       = module.My_module_for_basic_infracreation.RDS_endpoint
    app_tier_subnet_id = module.My_module_for_basic_infracreation.app_tier_subnet_id
  }
}
resource "aws_instance" "App_tier_instance" {

  ami                    = "ami-0195204d5dce06d99"
  depends_on             = [module.My_module_for_basic_infracreation]
  instance_type          = "t2.micro"
  key_name               = "3tierprojectkey"
  subnet_id              = module.My_module_for_basic_infracreation.app_tier_subnet_id //referncing output from module
  vpc_security_group_ids = module.My_module_for_basic_infracreation.app_tier_sg        //referncing output from module
  iam_instance_profile   = aws_iam_instance_profile.threetierprojectroleprofile.name
  user_data              = data.template_file.user_data.rendered

  tags = {
    name = "App_tier_instance"
  }

}