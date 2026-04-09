# data sorce for ami

data "aws_ami" "gitlab" {
  most_recent = true
  owners      = ["self"]

  tags = {
    Role = "gitlab"
  }
}

data "aws_ami" "jenkins" {
  most_recent = true
  owners      = ["self"]

  tags = {
    Role = "jenkins"
  }
}

# ec2 instance
resource "aws_instance" "gitlab_server" {
  ami           = data.aws_ami.gitlab.id
  instance_type = "m7i-flex.large"
  subnet_id     = var.private_subnet_ids[0]

  tags = {
    Name = "gitlab-server"
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.jenkins.id
  instance_type = "c7i-flex.large"
  subnet_id     = var.private_subnet_ids[0]

  tags = {
    Name = "jenkins-server"
  }
}
