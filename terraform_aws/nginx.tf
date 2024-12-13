
# Создаем ключ для SSH доступа
resource "aws_key_pair" "key_pair" {
  key_name   = "nginx-key"  # Название ключа
  public_key = file("~/nginx/nginx_key.pub")  # Путь к вашему публичному ключу
}


resource "aws_instance" "nginx_filebeat" {
  ami           = "ami-0a313d6098716f372"  # Используйте нужный AMI для вашей ОС (Ubuntu/Debian)
  instance_type = "t2.micro"  # Выберите нужный тип инстанса
  key_name      = aws_key_pair.key_pair.key_name



  # Устанавливаем Nginx и Filebeat через userdata
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx

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
