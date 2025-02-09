resource "aws_instance" "web_server" {
  ami           = var.ami_id
  subnet_id     = var.subnet_id
  security_groups    = [var.security_group_id] 
  instance_type = "t2.micro"  # Выберите нужный тип инстанса
  key_name      = var.key_name
  associate_public_ip_address = true  # Добавляем публичный IP

  tags = {
    Name = "WebServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y nginx postgresql-client
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF
}
