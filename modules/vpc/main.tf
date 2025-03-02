resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge({
    Name = "VPC-${var.environment}"},
    var.common_tags)
}

# Create public/private subnets, newbits = 3 so it creates subnets with a /19, each.value is 0, 1, 2.
# "each.value + length(var.availability_zones)"" will avoid overlapping CIDR blocks
resource "aws_subnet" "public" {
 for_each                 = {for i, az in var.availability_zones : az => i}

 vpc_id                   = aws_vpc.main.id
 cidr_block               = cidrsubnet(var.vpc_cidr, 3, each.value )
 availability_zone        = each.key
 map_public_ip_on_launch  = true
 tags = merge({
   Name =  "Public-Subnet-${each.key}-${var.environment}"},
    var.common_tags)
}
resource "aws_subnet" "private" {
  for_each          = {for i, az in var.availability_zones : az => i}
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, each.value + length(var.availability_zones))
  availability_zone = each.key
  tags = merge({
    Name = "Private-Subnet-${each.key}-${var.environment}"},
    var.common_tags)
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge({
    Name = "IGW-${var.environment}"},
    var.common_tags)
}

resource "aws_eip" "main" {
  count = length(var.availability_zones)
  domain = "vpc"

  tags = merge(
    { Name = "NAT-EIP-${var.environment}-${var.availability_zones[count.index]}" },
    var.common_tags
  )
}

resource "aws_nat_gateway" "main" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.main[count.index].id
  subnet_id     = aws_subnet.public[var.availability_zones[count.index]].id

  tags = merge(
    { Name = "NAT-Gateway-${var.environment}-${var.availability_zones[count.index]}" },
    var.common_tags
  )
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge({
    Name = "Public-Route-Table-${var.environment}"},
    var.common_tags)
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)
  
  vpc_id = aws_vpc.main.id
  
  route {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = merge(
    { Name = "Private-Route-Table-${var.environment}-${var.availability_zones[count.index]}" },
    var.common_tags
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[var.availability_zones[count.index]].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "null_resource" "validate_subnets" {
  triggers = {
    public_subnets_count  = length(aws_subnet.public)
    private_subnets_count = length(aws_subnet.private)
  }

  provisioner "local-exec" {
    command = "echo 'Subnets created: Public=${self.triggers.public_subnets_count}, Private=${self.triggers.private_subnets_count}'"
  }
}