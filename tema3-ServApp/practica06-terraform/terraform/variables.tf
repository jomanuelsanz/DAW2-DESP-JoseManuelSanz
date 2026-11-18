# variables.tf - Practica 06 (Jose Manuel Sanz - JMS)
variable "region" {
  description = "Region de AWS donde se crea la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "ami" {
  description = "ID de la AMI (Ubuntu Server 24.04 LTS en us-east-1)"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Nombre (tag Name) de la instancia"
  type        = string
  default     = "practica06-terraform-jms"
}

variable "key_name" {
  description = "Nombre del Key Pair ya existente en AWS (el mismo de la practica 4)"
  type        = string
}

