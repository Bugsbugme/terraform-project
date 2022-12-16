# Outputting the public IP address of the EC2 instance.
output "ec2_pub_ip" {
  value = aws_instance.devenv_instance.public_ip
}
