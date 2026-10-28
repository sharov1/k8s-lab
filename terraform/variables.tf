variable "project" {
  description = "Имя проекта, используется в тегах и именах ресурсов"
  type        = string
  default     = "k8s-lab"
}

variable "region" {
  description = "Регион AWS"
  type        = string
  default     = "eu-central-1"
}

variable "availability_zone" {
  description = "AZ, в которой живут все ноды"
  type        = string
  default     = "eu-central-1a"
}

variable "control_plane_instance_type" {
  description = "Тип инстанса для control plane (On-Demand)"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "Тип инстанса для воркеров (Spot)"
  type        = string
  default     = "t3.small"
}

variable "worker_count" {
  description = "Количество воркер-нод"
  type        = number
  default     = 2
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу на локальной машине"
  type        = string
  default     = "~/.ssh/k8s-learning.pub"
}

variable "vpc_cidr" {
  description = "Диапазон адресов VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Диапазон адресов публичной подсети"
  type        = string
  default     = "10.0.1.0/24"
}

variable "root_volume_size" {
  description = "Размер root-диска нод, ГБ"
  type        = number
  default     = 20
}
