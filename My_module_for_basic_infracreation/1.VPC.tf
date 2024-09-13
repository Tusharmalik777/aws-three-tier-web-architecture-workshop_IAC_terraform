resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "3tier_Custom_VPC"
  }
}
#---------------Creating Subnets for AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public-subnet-AZ1"
  }
}

resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-AZ1"
  }
}

resource "aws_subnet" "private_dbsubnet_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-DBsubnet-AZ1"
  }
}

#--------------------Creating subnets for AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public-subnet-AZ2"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-AZ2"
  }
}

resource "aws_subnet" "private_dbsubnet_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-DBsubnet-AZ2"
  }
}

#------------Intenet gateway---
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "3tier_IGW"
  }
}

#------Nat gateway-----(1 for each AZ for high availability)

resource "aws_eip" "Nat-Gateway-EIP-AZ1" {
}
resource "aws_nat_gateway" "NAT-GW-AZ1" {
  allocation_id = aws_eip.Nat-Gateway-EIP-AZ1.id
  subnet_id = aws_subnet.public_subnet_az1.id
  tags = {
    Name = "NAT-GW-AZ1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}
resource "aws_eip" "Nat-Gateway-EIP-AZ2" {
}
resource "aws_nat_gateway" "NAT-GW-AZ2" {
  allocation_id = aws_eip.Nat-Gateway-EIP-AZ2.id
  subnet_id = aws_subnet.public_subnet_az2.id
  tags = {
    Name = "NAT-GW-AZ2"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

#-----------Route_tables (one for public and two for )
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "ForPubSubAZ1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.PublicRouteTable.id

}
resource "aws_route_table_association" "ForPubSubAZ2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.PublicRouteTable.id

}
#Comment - Two private route table for two Nat gateways
resource "aws_route_table" "PrivateRTAZ1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT-GW-AZ1.id
  }
  tags = {
    Name = "PrivateRTAZ1"
  }
}

resource "aws_route_table_association" "ForPriAppSubAZ1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.PrivateRTAZ1.id

}

resource "aws_route_table" "PrivateRTAZ2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT-GW-AZ2.id
  }
  tags = {
    Name = "PrivateRTAZ2"
  }
}

resource "aws_route_table_association" "ForPriAppSubAZ2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.PrivateRTAZ2.id

}

#Comment-----Db Subnets are not included in any subnet for this project(Don't Know reason)
