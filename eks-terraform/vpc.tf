#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "k8s" {
  cidr_block = "10.0.0.0/16"

  tags = "${map(
    "Name", "${local.resources-name}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )}"
}

resource "aws_subnet" "k8s" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.k8s.id}"

  tags = "${map(
    "Name", "${local.resources-name}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )}"
}

resource "aws_internet_gateway" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

  tags = {
    Name = "${local.resources-name}"
  }
}

resource "aws_route_table" "k8s" {
  vpc_id = "${aws_vpc.k8s.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s.id}"
  }
}

resource "aws_route_table_association" "k8s" {
  count = 2

  subnet_id      = "${aws_subnet.k8s.*.id[count.index]}"
  route_table_id = "${aws_route_table.k8s.id}"
}
