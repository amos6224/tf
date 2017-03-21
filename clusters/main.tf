provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "mycluster" {
  image_id                  = "ami-40d28157"
  instance_type             = "t2.micro"
  security_groups           = ["${aws_security_group.mycluster-sec.id}"]
  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, Jeff" > index.html
                nohup busybox httpd -f -p "${var.server_port}" &
                EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mycluster-sec" {
  name = "mycluster-security_groups"
  ingress {
    from_port = "${var.server_port}"
    to_port   = "${var.server_port}"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/10"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "mycluster-asg" {
  launch_configuration = "${aws_launch_configuration.mycluster.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 2
  max_size = 10
  tag {
    key                     = "Name"
    value                   = "terraform-asg-mycluster"
    propagate_at_launch     = true
  }
}
