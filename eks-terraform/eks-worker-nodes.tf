#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#

resource "aws_iam_role" "k8s-nodes" {
  name = "${local.resources-name}-nodes"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.k8s-nodes.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.k8s-nodes.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.k8s-nodes.name}"
}

resource "aws_iam_instance_profile" "k8s-nodes" {
  name = "${aws_iam_role.k8s-nodes.name}"
  role = "${aws_iam_role.k8s-nodes.name}"
}

resource "aws_security_group" "k8s-nodes" {
  name        = "${local.resources-name}-nodes"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.k8s.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${map(
    "Name", "${local.resources-name}-nodes",
    "kubernetes.io/cluster/${var.cluster-name}", "owned",
  )}"
}

resource "aws_security_group_rule" "k8s-nodes-ingress-self" {
  description              = "Allow node to communicate with each other"
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.k8s-nodes.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "k8s-nodes-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.k8s-nodes.id}"
  source_security_group_id = "${aws_security_group.k8s-masters.id}"
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "k8s-nodes-ingress-workstation-ssh" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to ssh to worker nodes"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port         = 22
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "k8s-nodes-ingress-workstation-node-port-services" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to reach k8s NodePort services"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port         = 30000
  to_port           = 32767
  type              = "ingress"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.k8s.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  k8s-nodes-userdata = <<USERDATA
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.k8s.endpoint}' --b64-cluster-ca '${aws_eks_cluster.k8s.certificate_authority.0.data}' '${aws_eks_cluster.k8s.id}'
USERDATA
}

resource "aws_key_pair" "k8s" {
  key_name   = "${local.resources-name}"
  public_key = "${var.ssh-public-key}"
}

resource "aws_launch_configuration" "k8s" {
  name_prefix                 = "${local.resources-name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.k8s-nodes.name}"
  security_groups             = ["${aws_security_group.k8s-nodes.id}"]
  user_data_base64            = "${base64encode(local.k8s-nodes-userdata)}"
  key_name                    = "${aws_key_pair.k8s.key_name}"

  # https://aws.amazon.com/ec2/pricing/on-demand/
  instance_type = "t3.medium"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "k8s" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.k8s.id}"
  max_size             = 2
  min_size             = 1
  name                 = "${local.resources-name}"
  vpc_zone_identifier  = ["${aws_subnet.k8s.*.id}"]

  tag {
    key                 = "Name"
    value               = "${local.resources-name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
