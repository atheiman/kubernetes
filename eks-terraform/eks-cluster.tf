#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "k8s-masters" {
  name = "${local.resources-name}-masters"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s-masters-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.k8s-masters.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-masters-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.k8s-masters.name}"
}

resource "aws_security_group" "k8s-masters" {
  name        = "${local.resources-name}-masters"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.resources-name}-masters"
  }
}

resource "aws_security_group_rule" "k8s-masters-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.k8s-masters.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "k8s-masters-ingress-workstation-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.k8s-masters.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "k8s" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.k8s-masters.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.k8s-masters.id}"]
    subnet_ids         = ["${module.vpc.private_subnets}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.k8s-masters-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.k8s-masters-AmazonEKSServicePolicy",
  ]
}

resource "local_file" "k8s-manifest-aws-auth-config-map" {
  filename = "${path.module}/generated-manifests/aws-auth-config-map.yaml"

  content = <<CONTENT
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.k8s-nodes.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONTENT
}
