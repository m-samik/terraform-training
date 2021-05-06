variable "x" {
  type = string
  default = "Hello World"
}

output "value" {
  value = "${var.x}"
}