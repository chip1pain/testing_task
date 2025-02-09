# Генерация приватного ключа для SSH
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Создание ключа AWS с использованием публичного ключа из tls_private_key
resource "aws_key_pair" "nginx_key" {
  key_name   = "nginx-key"
  public_key = tls_private_key.default.public_key_openssh
}

