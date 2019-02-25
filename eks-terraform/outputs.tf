output "Post-provision-commands" {
  value = <<VALUE

# Get worker nodes
aws autoscaling describe-auto-scaling-instances --query 'AutoScalingInstances[? AutoScalingGroupName == `${aws_autoscaling_group.k8s.name}`]'

# Show detailed cluster information
aws eks describe-cluster --name "${aws_eks_cluster.k8s.id}"

# Update KUBECONFIG (~/.kube/config) to use new cluster
aws eks update-kubeconfig --name "${aws_eks_cluster.k8s.id}" --alias "eks-${aws_eks_cluster.k8s.id}"

# Verify connectivity to new cluster
kubectl version

# Create basic cluster resources
kubectl apply --recursive --filename=./manifests

# Wait for worker nodes to become ready
kubectl get nodes
VALUE
}
