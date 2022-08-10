# Uncomment below to create a demo Virtual Machine

# resource "aws_security_group" "ingress_all_1" {
#   name   = "allow-icmp-ssh-http-locust-iperf-sg"
#   vpc_id = aws_vpc.vpc_1.id
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 8089
#     to_port     = 8089
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 5001
#     to_port     = 5001
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   // Terraform removes the default rule
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# resource "aws_security_group" "ingress_all_2" {
#   provider = aws.region2
#   name     = "allow-icmp-ssh-http-locust-iperf-sg"
#   vpc_id   = aws_vpc.vpc_2.id
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 8089
#     to_port     = 8089
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 5001
#     to_port     = 5001
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   // Terraform removes the default rule
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# # Create NIC for the EC2 instances
# resource "aws_network_interface" "nic1" {
#   subnet_id       = aws_subnet.subnet_1.id
#   security_groups = ["${aws_security_group.ingress_all_1.id}"]
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# resource "aws_network_interface" "nic2" {
#   provider        = aws.region2
#   subnet_id       = aws_subnet.subnet_2.id
#   security_groups = ["${aws_security_group.ingress_all_2.id}"]
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# # Create the Key Pair
# resource "aws_key_pair" "ssh_key_1" {
#   key_name   = "ssh_key-${random_pet.name.id}"
#   public_key = var.public_key
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# resource "aws_key_pair" "ssh_key_2" {
#   provider   = aws.region2
#   key_name   = "ssh_key-${random_pet.name.id}"
#   public_key = var.public_key
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# # Create the Ubuntu EC2 instances
# resource "aws_instance" "ec2_instance_1" {
#   ami           = var.ec2_ami1
#   instance_type = var.ec2_instance_type
#   network_interface {
#     network_interface_id = aws_network_interface.nic1.id
#     device_index         = 0
#   }
#   key_name  = aws_key_pair.ssh_key_1.id
#   user_data = file("../user-data-ubuntu.sh")
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# resource "aws_instance" "ec2_instance_2" {
#   provider      = aws.region2
#   ami           = var.ec2_ami2
#   instance_type = var.ec2_instance_type
#   network_interface {
#     network_interface_id = aws_network_interface.nic2.id
#     device_index         = 0
#   }
#   key_name  = aws_key_pair.ssh_key_2.id
#   user_data = file("../user-data-ubuntu.sh")
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# # Assign a public IP to both EC2 instances
# resource "aws_eip" "public_ip_1" {
#   instance = aws_instance.ec2_instance_1.id
#   vpc      = true
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }
# resource "aws_eip" "public_ip_2" {
#   provider = aws.region2
#   instance = aws_instance.ec2_instance_2.id
#   vpc      = true
#   tags = {
#     Name = "${var.tag_name}-${random_pet.name.id}"
#   }
# }

# output "aws_ec2_transit_gateway_1" {
#   description = "Transit Gateway ID for Region 1"
#   value = aws_ec2_transit_gateway.transit_gw_1.id
# }

# output "aws_ec2_transit_gateway_2" {
#   description = "Transit Gateway ID for Region 2"
#   value = aws_ec2_transit_gateway.transit_gw_2.id
# }

# # Private IPs of the demo Ubuntu instances
# output "ec2_private_ip_1" {
#   description = "Private ip address for EC2 instance for Region 1"
#   value       = aws_instance.ec2_instance_1.private_ip
# }

# output "ec2_private_ip_2" {
#   description = "Private ip address for EC2 instance for Region 2"
#   value       = aws_instance.ec2_instance_2.private_ip
# }

# # Public IPs of the demo Ubuntu instances
# output "ec2_public_ip_1" {
#   description = "Elastic ip address for EC2 instance for Region 1"
#   value       = aws_eip.public_ip_1.public_ip
# }

# output "ec2_public_ip_2" {
#   description = "Elastic ip address for EC2 instance for Region 2"
#   value       = aws_eip.public_ip_2.public_ip
# }
