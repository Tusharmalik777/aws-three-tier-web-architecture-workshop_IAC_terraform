module "vpc_rds_sg" {
    source = "./modules/vpc_rds_sg"
}

module "app_tier_module" {
    source = "./modules/app_tier_module"
    app_tier_subnet_id = module.vpc_rds_sg.app_tier_subnet_id
    app_tier_security_group_id = module.vpc_rds_sg.app_tier_sg
    ami_id = var.ami_id_app_tier
    instance_type = var.instance_type_app_tier
    RDS_endpoint = module.vpc_rds_sg.RDS_endpoint

}