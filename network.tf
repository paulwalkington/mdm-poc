# network.tf

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.main_vpc.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = data.aws_availability_zones.available.names[count.index]
 
 tags = {
   Name = "Public Subnet ${count.index + 1}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.main_vpc.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = data.aws_availability_zones.available.names[count.index]
 
 tags = {
   Name = "Private Subnet ${count.index + 1}"
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.main_vpc.id
 
 tags = {
   Name = "Project VPC IG"
 }
}

resource "aws_route_table" "public_route_table" {
 vpc_id = aws_vpc.main_vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "Public Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
 vpc_id = aws_vpc.main_vpc.id
 count = length(var.private_subnet_cidrs)
 
 route {
   cidr_block = "0.0.0.0/0"
   nat_gateway_id = element(aws_nat_gateway.natgateway[*].id, count.index)
 }
 
 tags = {
   Name = "Private Route Table"
 }
}

resource "aws_route_table_association" "private_subnet_asso" {
 count          = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = element(aws_route_table.private_route_table[*].id, count.index)
}

# # Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
resource "aws_eip" "eip_natgw" {
    count      = length(var.private_subnet_cidrs)
    domain     = "vpc"
}

resource "aws_nat_gateway" "natgateway" {
    count         = length(var.private_subnet_cidrs)
    subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
    allocation_id = element(aws_eip.eip_natgw.*.id, count.index)
}




# # Create var.az_count private subnets, each in a different AZ
# resource "aws_subnet" "private" {
#     count             = var.az_count
#     cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
#     availability_zone = data.aws_availability_zones.available.names[count.index]
#     vpc_id            = aws_vpc.main.id
# }

# # Create var.az_count public subnets, each in a different AZ
# resource "aws_subnet" "public" {
#     count                   = var.az_count
#     cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
#     availability_zone       = data.aws_availability_zones.available.names[count.index]
#     vpc_id                  = aws_vpc.main.id
#     map_public_ip_on_launch = true
# }

# # Internet Gateway for the public subnet
# resource "aws_internet_gateway" "gw" {
#     vpc_id = aws_vpc.main.id
# }

# # Route the public subnet traffic through the IGW
# resource "aws_route" "internet_access" {
#     route_table_id         = aws_vpc.main.main_route_table_id
#     destination_cidr_block = "0.0.0.0/0"
#     gateway_id             = aws_internet_gateway.gw.id
# }

# # Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity
# resource "aws_eip" "gw" {
#     count      = var.az_count
#     domain = "vpc"
#     depends_on = [aws_internet_gateway.gw]
# }

# resource "aws_nat_gateway" "gw" {
#     count         = var.az_count
#     subnet_id     = element(aws_subnet.public.*.id, count.index)
#     allocation_id = element(aws_eip.gw.*.id, count.index)
# }

# # Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
# resource "aws_route_table" "private" {
#     count  = var.az_count
#     vpc_id = aws_vpc.main.id

#     route {
#         cidr_block     = "0.0.0.0/0"
#         nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
#     }
# }

# # Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
# resource "aws_route_table_association" "private" {
#     count          = var.az_count
#     subnet_id      = element(aws_subnet.private.*.id, count.index)
#     route_table_id = element(aws_route_table.private.*.id, count.index)
# }