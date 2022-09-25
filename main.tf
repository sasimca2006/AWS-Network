resource "aws_vpc" "MYVPC" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "MYVPC"
  }
}
resource "aws_subnet" "web_public" {
  vpc_id = aws_vpc.MYVPC.id
  cidr_block = "172.16.0.0/17"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "WEBSUB"
  }
}
resource "aws_subnet" "app_private" {
  vpc_id = aws_vpc.MYVPC.id
  cidr_block = "172.16.128.0/17"
  availability_zone = "us-east-1b"
  tags = {
    Name = "APPSUB"
  }
}

resource "aws_internet_gateway" "webigw" {
  vpc_id = aws_vpc.MYVPC.id
  tags = {
    Name = "WEBIGW"
  }
}

resource "aws_route_table" "web_publicassoc" {
  vpc_id = aws_vpc.MYVPC.id
  tags = {
    Name = "WEBROUTE"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webigw.id
  }
}
resource "aws_route_table_association" "webpub_assoc" {
  route_table_id = aws_route_table.web_publicassoc.id
  subnet_id = aws_subnet.web_public.id
}
resource "aws_eip" "elp" {
  vpc = "true"
}

resource "aws_nat_gateway" "public_nat" {
    allocation_id = aws_eip.elp.id
    subnet_id = aws_subnet.web_public.id
  tags = {
    Name = "NAT"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.MYVPC.id
  tags = {
    Name = "APPROUTE"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public_nat.id
  }
}
resource "aws_route_table_association" "private_asso" {
  route_table_id = aws_route_table.private_route.id
  subnet_id = aws_subnet.app_private.id
}