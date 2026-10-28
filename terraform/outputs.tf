output "account_id" {
  description = "ID аккаунта AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "my_cidr" {
  description = "Мой IP в формате CIDR для security group"
  value       = local.my_cidr
}

output "ubuntu_ami_id" {
  description = "AMI Ubuntu 24.04, который будет использован для нод"
  value       = data.aws_ssm_parameter.ubuntu_ami.value
  sensitive   = true
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "k8s_nodes_sg_id" {
  value = aws_security_group.k8s_nodes.id
}

output "control_plane_public_ip" {
  value = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  value = aws_instance.control_plane.private_ip
}

output "worker_public_ips" {
  value = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  value = aws_instance.worker[*].private_ip
}
