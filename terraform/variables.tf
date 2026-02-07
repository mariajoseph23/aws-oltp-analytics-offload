variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "oltp-analytics-offload"
}

variable "db_username" {
  type    = string
  default = "admin"
}

# For demo only: allow your public IP /32
variable "allowed_cidr" {
  type        = string
  description = "CIDR allowed to access MySQL (e.g., your public IP /32)"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
