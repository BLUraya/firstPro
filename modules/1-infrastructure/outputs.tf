output "gitlab_instance_id" {
  value = aws_instance.gitlab_server.id
}

output "jenkins_instance_id" {
  value = aws_instance.jenkins_server.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main_cluster.name
}


output "eks_cluster_security_group_id" {
  value = aws_eks_cluster.main_cluster.vpc_config[0].cluster_security_group_id
}

output "eks_node_group_asg_name" {
  
  value = aws_eks_node_group.main_node_group.resources[0].autoscaling_groups[0].name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main_cluster.endpoint
}

output "eks_cluster_ca" {
  value = aws_eks_cluster.main_cluster.certificate_authority[0].data
}