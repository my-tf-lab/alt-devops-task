data "aws_ami" "amazon2" {

  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-*-hvm-*-x86_64-gp2"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}


resource "aws_key_pair" "core" {
  key_name   = local.node_name
  public_key = data.hcp_vault_secrets_app.demo.secrets["public_key"]
}

resource "aws_launch_template" "worker_nodes" {

  name          = local.node_name
  key_name      = local.node_name
  description   = "Alti DevOps task launch template"
  instance_type = "t3.micro"
  image_id      =  data.aws_ami.amazon2.id

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 10
      volume_type           = "gp3"
    }
  }
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.app.id]
    delete_on_termination       = true
  }

  tags = local.tags

}

resource "aws_launch_template" "bastion_nodes" {

  name          = local.bastion_name
  key_name      = local.node_name
  description   = "Alti DevOps task bastion launch template"
  instance_type = "t3.micro"
  image_id      =  data.aws_ami.amazon2.id

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 10
      volume_type           = "gp3"
    }
  }
  
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.bastion.id]
    delete_on_termination       = true
  }

  tags = local.tags

}

resource "aws_autoscaling_group" "app" {

  name                = local.bastion_name
  max_size            = 5
  min_size            = 1
  desired_capacity    = 1
  force_delete        = true
  vpc_zone_identifier = data.aws_subnets.private.ids

  launch_template {
    id      = aws_launch_template.worker_nodes.id
    version = "$Latest"
  }

  tag {
    key                 = "terraform_state"
    value               = "level2"
    propagate_at_launch = true
  }

  tag {
    key                 = "terraform_workspace"
    value               = var.env_code
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "bastion" {

  name                = local.node_name
  max_size            = 3
  min_size            = 1
  desired_capacity    = 1
  force_delete        = true
  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id      = aws_launch_template.bastion_nodes.id
    version = "$Latest"
  }

  tag {
    key                 = "terraform_state"
    value               = "level2"
    propagate_at_launch = true
  }

  tag {
    key                 = "terraform_workspace"
    value               = var.env_code
    propagate_at_launch = true
  }
}
