resource "aws_key_pair" "main" {
  key_name   = "${var.project}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.control_plane_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k8s_nodes.id]
  key_name               = aws_key_pair.main.key_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "${var.project}-control-plane"
    Role = "control-plane"
  }
}

resource "aws_instance" "worker" {
  count = var.worker_count

  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.worker_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k8s_nodes.id]
  key_name               = aws_key_pair.main.key_name

  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type             = "one-time"
      instance_interruption_behavior = "terminate"
    }
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "${var.project}-worker-${count.index + 1}"
    Role = "worker"
  }
}
