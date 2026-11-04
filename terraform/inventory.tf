locals {
  # Имена воркеров: worker-1, worker-2, ...
  worker_names = [for i in range(var.worker_count) : "worker-${i + 1}"]

  kubespray_inventory = {
    all = {
      vars = {
        ansible_user                        = "ubuntu"
        supplementary_addresses_in_ssl_keys = [aws_instance.control_plane.public_ip]
        ansible_python_interpreter          = "/usr/bin/python3"
      }

      hosts = merge(
        {
          "control-plane" = {
            ansible_host     = aws_instance.control_plane.public_ip
            ip               = aws_instance.control_plane.private_ip
            etcd_member_name = "etcd1"
          }
        },
        {
          for i, name in local.worker_names : name => {
            ansible_host = aws_instance.worker[i].public_ip
            ip           = aws_instance.worker[i].private_ip
          }
        }
      )

      children = {
        kube_control_plane = { hosts = { "control-plane" = {} } }
        etcd               = { hosts = { "control-plane" = {} } }
        kube_node          = { hosts = { for name in local.worker_names : name => {} } }
      }
    }
  }
}

resource "local_file" "kubespray_inventory" {
  filename        = "${path.module}/../kubespray/inventory/k8s-lab/hosts.yaml"
  content         = yamlencode(local.kubespray_inventory)
  file_permission = "0644"
}
