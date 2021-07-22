#Create the VPC
resource "aws_vpc" "Main" {
  cidr_block       = var.main_vpc_cidr
  instance_tenancy = "default"
}
#Create Internet Gateway 
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Main.id
}



#Create all public subnets
resource "aws_subnet" "publicSubnets" {
  vpc_id     = aws_vpc.Main.id
  for_each   = var.publicSubnets
  cidr_block = each.value
  tags = {
    Name = each.key
  }
}
#Create all private subnets
resource "aws_subnet" "privateSubnets" {
  vpc_id     = aws_vpc.Main.id
  for_each   = var.privateSubnets
  cidr_block = each.value
  tags = {
    Name = each.key
  }
}




#Route tables for Public Subnets
resource "aws_route_table" "PublicRTs" {
  count  = length(var.publicSubnets)
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "PublicRT${count.index}"
  }
}
#Route tables for Private Subnets
resource "aws_route_table" "PrivateRTs" {
  count  = length(var.privateSubnets)
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    Name = "PrivateRT${count.index}"
  }
}




#Route table Association with Public Subnets
resource "aws_route_table_association" "PublicRTassociation" {
  count          = length(var.publicSubnets)
  subnet_id      = aws_subnet.publicSubnets["public${count.index + 1}"].id
  route_table_id = aws_route_table.PublicRTs[count.index].id
}

#Route table Association with Private Subnets
resource "aws_route_table_association" "PrivateRTassociation" {
  count          = length(var.privateSubnets)
  subnet_id      = aws_subnet.privateSubnets["private${count.index + 1}"].id
  route_table_id = aws_route_table.PrivateRTs[count.index].id
}




resource "aws_eip" "nateIP" {
  vpc = true
}
#Creating the NAT Gateway
resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.publicSubnets["public1"].id
}
