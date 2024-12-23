
# Создаем ключ для SSH доступа
resource "aws_key_pair" "key_pair" {
  key_name   = "nginx-key"  # Название ключа
  public_key = file("~/nginx/nginx_key.pub")  # Путь к вашему публичному ключу
}


# Создаем Security Group для Nginx и Filebeat
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = module.vpc.vpc_id  # Привязка к VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH для всех (использовать с осторожностью)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # HTTPS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Разрешаем весь исходящий трафик
  }

  tags = {
    Name = "Nginx and Filebeat Security Group"
  }
}

resource "aws_instance" "nginx_filebeat" {
  ami           = "ami-0a313d6098716f372"  # Используйте нужный AMI для вашей ОС (Ubuntu/Debian)
  instance_type = "t2.micro"  # Выберите нужный тип инстанса
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]  # Привязка Security Group
  subnet_id              = module.vpc.public_subnets[0]      # Привязка к публичной подсети VPC
  associate_public_ip_address = true  # Добавляем публичный IP


  # Устанавливаем Nginx и Filebeat через userdata
  user_data = <<-EOF
              #!/bin/bash
              apt update && DEBIAN_FRONTEND=noninteractive apt install -y nginx apache2-utils  python3-pip
              pip3 install psutil requests 
              systemctl start nginx
              systemctl enable nginx

              # Генерация трафика
              ab -n 1000 -c 10 http://localhost/ > /dev/null

              # Устанавливаем Filebeat
              wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.5.1-amd64.deb
              dpkg -i filebeat-8.5.1-amd64.deb

              # Настройка Filebeat
              echo "
              filebeat.inputs:
                - type: log
                  enabled: true
                  paths:
                    - /var/log/nginx/access.log
                    - /var/log/nginx/error.log

              output.logstash:
                hosts: [\"${data.kubernetes_service.logstashUrl.status[0].load_balancer[0].ingress[0].hostname}\"]  # Используем IP Kubernetes или балансировщика нагрузки
                ssl.enabled: false
              " > /etc/filebeat/filebeat.yml

              # Запуск и включение Filebeat
              systemctl start filebeat
              systemctl enable filebeat
              EOF

  tags = {
    Name = "Nginx and Filebeat Server"
  }
}
