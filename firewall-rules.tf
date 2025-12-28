# Firewall rules for production VPC
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  # Overly permissive ingress rule for SSH
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # CRITICAL: Should be restricted to bastion host
  }

  # Overly permissive ingress rule for HTTP
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acceptable for public web server, but could be restricted to load balancer
  }

  # Missing egress restrictions - allows all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # CRITICAL: No egress filtering could lead to data exfiltration
  }
}

resource "aws_security_group" "database" {
  name        = "database-sg"
  description = "Security group for MySQL database"
  vpc_id      = var.vpc_id

  # Database port open to entire VPC (including web servers)
  ingress {
    description = "MySQL from web servers"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Should be restricted to specific application subnets
  }

  # No egress restrictions
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}