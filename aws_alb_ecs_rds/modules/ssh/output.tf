# Если хочешь сохранить приватный ключ локально, можно использовать output:
output "private_key" {
  value = tls_private_key.default.private_key_pem
  sensitive = true  # Чтобы скрыть в выводах
}

output "key_name" {
  value = aws_key_pair.nginx_key.key_name
}