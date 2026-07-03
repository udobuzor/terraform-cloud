resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      },
    ]
  })

  tags = merge(var.tags, { Name = "aws-assume-role" })
}

resource "aws_iam_policy" "policy" {
  name        = "ec2_instance_policy"
  description = "A test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:Describe*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = merge(var.tags, { Name = "aws-assume-policy" })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "ip" {
  name = "aws_instance_profile_test"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_sns_topic" "sns" {
  name = "Default_CloudWatch_Alarms_Topic"
}

# resource "random_shuffle" "az_list" {
#   input = data.aws_availability_zones.available.names
# }

resource "random_shuffle" "az_list" {
  input = var.azs
}

resource "aws_launch_template" "bastion-launch-template" {
  # aws_lb_target_group
  image_id               = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.keypair

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  placement {
    availability_zone = element(random_shuffle.az_list.result, 0)
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "oddshare-bastion" })
  }

  user_data = filebase64("${path.module}/bastion.sh")
}

resource "aws_autoscaling_group" "bastion-asg" {
  name                      = "bastion-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       = [var.public_subnets[0], var.public_subnets[1]]

  launch_template {
    id      = aws_launch_template.bastion-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "oddshare-bastion"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "nginx-launch-template" {
  image_id               = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.nginx_sg_id]
  key_name               = var.keypair

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  placement {
    availability_zone = element(random_shuffle.az_list.result, 0)
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "oddshare-nginx" })
  }

  user_data = filebase64("${path.module}/nginx.sh")
}

resource "aws_autoscaling_group" "nginx-asg" {
  name                      = "nginx-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       = [var.public_subnets[0], var.public_subnets[1]]

  launch_template {
    id      = aws_launch_template.nginx-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "oddshare-nginx"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_nginx" {
  autoscaling_group_name = aws_autoscaling_group.nginx-asg.id
  lb_target_group_arn    = var.nginx_target_group_arn
}

resource "aws_autoscaling_notification" "notifications" {
  group_names = [
    aws_autoscaling_group.bastion-asg.name,
    aws_autoscaling_group.nginx-asg.name,
  ]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.sns.arn
}


resource "aws_launch_template" "wordpress-launch-template" {
  image_id               = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.webserver_sg_id]
  key_name               = var.keypair

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  placement {
    availability_zone = element(random_shuffle.az_list.result, 0)
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "oddshare-wordpress" })
  }

  user_data = filebase64("${path.module}/wordpress.sh")
}

resource "aws_autoscaling_group" "wordpress-asg" {
  name                      = "wordpress-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       = [var.private_subnets[0], var.private_subnets[1]]

  launch_template {
    id      = aws_launch_template.wordpress-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "oddshare-wordpress"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_wordpress" {
  autoscaling_group_name = aws_autoscaling_group.wordpress-asg.id
  lb_target_group_arn    = var.wordpress_target_group_arn
}

# ---------------- TOOLING ----------------

resource "aws_launch_template" "tooling-launch-template" {
  image_id               = var.ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [var.webserver_sg_id]
  key_name               = var.keypair

  iam_instance_profile {
    name = aws_iam_instance_profile.ip.id
  }

  placement {
    availability_zone = element(random_shuffle.az_list.result, 0)
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "oddshare-tooling" })
  }

  user_data = filebase64("${path.module}/tooling.sh")
}

resource "aws_autoscaling_group" "tooling-asg" {
  name                      = "tooling-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       = [var.private_subnets[0], var.private_subnets[1]]

  launch_template {
    id      = aws_launch_template.tooling-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "oddshare-tooling"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_tooling" {
  autoscaling_group_name = aws_autoscaling_group.tooling-asg.id
  lb_target_group_arn    = var.tooling_target_group_arn
}
