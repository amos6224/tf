variable "server_port" {
  description = "This Serve the Web"
  default = 8080
}

data "aws_availability_zones" "all" {}
