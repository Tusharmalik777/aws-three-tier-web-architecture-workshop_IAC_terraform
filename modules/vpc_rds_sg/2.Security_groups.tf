#Author - Tushar
#Type_of_resources = Security groups
#Number of security groups = 5


#SG for Internet load balancer to be able to accessed by internet
resource "aws_security_group" "internet_facing_lb_sg" {
  name        = "internet_facing_lb_sg"
  description = "External load balancer security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from outside"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "internet_facing_lb_sg"
  }
}

#SG for Web tier EC2 instaces
resource "aws_security_group" "Web_tier_sg" {
  name        = "Web_tier_sg"
  description = "Web_tier_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from outside"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description     = "Allow HTTP from Internet facing Load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internet_facing_lb_sg.id]
  }
  ingress {
    description = "Allow SSH from Internet " #Best practice is to specify MY IP only instead of Internet
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  // "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "Web_tier_sg"
  }

}

#Security group for Internal load balancer

resource "aws_security_group" "internal_lb_sg" {
  name        = "internal_lb_sg"
  description = "internal_lb_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow HTTP from Web tier security group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.Web_tier_sg.id]
  }

  tags = {
    name = "internal_lb_sg"
  }

}

#Security group for private instances or App_tier instances

resource "aws_security_group" "Private_App_tier_sg" {
  name        = "Private_App_tier_sg"
  description = "Private_App_tier_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Custom TCP traffic from Internal load balancer "
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }
  ingress {
    description = "Allow Custom TCP traffic from outside world for testing purposes" #Best practice is to specify MY IP only instead of Internet
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH traffic from outside world checking configuration" #Best practice is to specify MY IP only instead of Internet
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  // "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "Private_App_tier_sg"
  }
}

#Security group for private database RDS instances

resource "aws_security_group" "DB_tier_sg" {
  name        = "DB_tier_sg"
  description = "DB_tier_sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Custom TCP traffic from App tier instances "
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.Private_App_tier_sg.id]
  }
  tags = {
    name = "DB_tier_sg"
  }
}
