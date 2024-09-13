module "My_module_for_basic_infracreation" {
  source = "./My_module_for_basic_infracreation"
}

#Here I will try to create App tier instance and try to create AMI from it

resource "aws_iam_instance_profile" "threetierprojectroleprofile" {
  name = "threetierprojectroleprofile"
  role = "3tierprojectrole"
}



data "template_file" "user_data" {
  template = file("App_tier_script.sh.tpl")

  vars = {
    RDS_endpoint = module.My_module_for_basic_infracreation.RDS_endpoint
    app_tier_subnet_id = module.My_module_for_basic_infracreation.app_tier_subnet_id
  }
}
resource "aws_instance" "App_tier_instance" {

  ami                    = "ami-0195204d5dce06d99"
  depends_on = [ module.My_module_for_basic_infracreation ]
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