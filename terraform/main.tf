# Кто я: аккаунт и пользователь, от имени которых работает Terraform
data "aws_caller_identity" "current" {}

# Мой текущий публичный IP (для правил security group)
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

# Свежий AMI Ubuntu 24.04 — тот же SSM-параметр, что в CLI-тесте
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

locals {
  # checkip возвращает IP с переводом строки в конце, chomp его убирает
  my_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}
