# https://docs.aws.amazon.com/eks/latest/userguide/create-public-private-vpc.html

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.resources-name}"
  cidr = "10.0.0.0/22"

  azs             = ["us-east-1c", "us-east-1d"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = "${map(
    "Terraform", "terraform-aws-modules/vpc/aws",
    "Description", "k8s vpc ${local.resources-name}",
  )}"

  vpc_tags = "${map(
    "Name", "${local.resources-name}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )}"

  public_subnet_tags = "${map(
    "Name", "${local.resources-name}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
    "kubernetes.io/role/elb", "1",
  )}"

  private_subnet_tags = "${map(
    "Name", "${local.resources-name}",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
    "kubernetes.io/role/internal-elb", "1",
  )}"
}
