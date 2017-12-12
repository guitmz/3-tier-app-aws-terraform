# security group to be attached to our instance
resource "aws_security_group" "3-tier-guilherme-security-group" {
  name        = "3-tier Guilherme Security Group"
  description = "3-tier Guilherme Security Group"

  # allowing SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allowing web connections since it runs a web server
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${ aws_vpc.vpc_guilherme.id }"
}
