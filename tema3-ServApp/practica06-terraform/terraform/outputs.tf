# outputs.tf - Practica 06 (Jose Manuel Sanz - JMS)
output "instance_id" {
  description = "ID de la instancia EC2"
  value       = aws_instance.practica06.id
}

output "public_ip" {
  description = "IP publica de la instancia EC2"
  value       = aws_instance.practica06.public_ip
}

output "security_group_id" {
  description = "ID del Security Group creado"
  value       = aws_security_group.practica06_sg.id
}

output "ssh_command" {
  description = "Comando para conectarse por SSH"
  value       = "ssh -i practica04.pem ubuntu@${aws_instance.practica06.public_ip}"
}