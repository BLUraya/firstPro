terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# sg for alb
resource "aws_security_group" "alb_sg" {
  name   = "main-alb-sg"
  vpc_id = var.vpc_id

  # מאפשר גישה ב-HTTP מכל העולם
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # מאפשר ל-ALB לדבר עם כל המשאבים הפנימיים שלנו
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- alb
resource "aws_lb" "main_alb" {
  name               = "main-project-alb"
  internal           = false 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

# --- tg
resource "aws_lb_target_group" "gitlab_tg" {
  name     = "gitlab-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080 
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "eks_tg" {
  name     = "eks-tg"
  port     = 30080 
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# --- target group attachment
resource "aws_lb_target_group_attachment" "gitlab_attach" {
  target_group_arn = aws_lb_target_group.gitlab_tg.arn
  target_id        = var.gitlab_instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "jenkins_attach" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = var.jenkins_instance_id
  port             = 8080
}


resource "aws_autoscaling_attachment" "eks_asg_attach" {
  autoscaling_group_name = var.eks_asg_name
  lb_target_group_arn    = aws_lb_target_group.eks_tg.arn
}

# --- listener and rules
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"

  
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found (Route not configured)"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "gitlab_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gitlab_tg.arn
  }

  condition {
    path_pattern {
      values = ["/gitlab*"]
    }
  }
}

resource "aws_lb_listener_rule" "jenkins_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  condition {
    path_pattern {
      values = ["/jenkins*"]
    }
  }
}

resource "aws_lb_listener_rule" "weather_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_tg.arn
  }

  condition {
    path_pattern {
      values = ["/weather*"]
    }
  }
}
