resource "aws_security_group" "k8s_nodes" {
  name        = "${var.project}-nodes"
  description = "Kubernetes cluster nodes"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-nodes"
  }
}

resource "aws_vpc_security_group_ingress_rule" "intra_cluster" {
  security_group_id            = aws_security_group.k8s_nodes.id
  referenced_security_group_id = aws_security_group.k8s_nodes.id
  ip_protocol                  = "-1"
  description                  = "All traffic between cluster nodes"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_ipv4         = local.my_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "SSH from admin IP"
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api" {
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_ipv4         = local.my_cidr
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  description       = "Kubernetes API from admin IP"
}

resource "aws_vpc_security_group_ingress_rule" "nodeport" {
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_ipv4         = local.my_cidr
  ip_protocol       = "tcp"
  from_port         = 30000
  to_port           = 32767
  description       = "NodePort services from admin IP"
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.k8s_nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "All outbound traffic"
}
