output "ec2_pub_ip" {
  value = aws_instance.devenv_instance.public_ip
}
