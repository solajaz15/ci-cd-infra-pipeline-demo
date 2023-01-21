
output "jenkins-host-ip" {
  description = "Jenkins host public IP address"
  value       = "http://${aws_instance.jenkins-server.public_ip}:8080"
}

output "sonarqube-host-ip" {
  description = "Jenkins host public IP address"
  value       = "http://${aws_instance.sonarqube-server.public_ip}:9000"
}