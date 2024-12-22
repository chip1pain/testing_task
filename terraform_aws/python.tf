data "kubernetes_service" "prometheus_pushgateway_external" {
  metadata {
    name      = "prometheus-pushgateway-external"
    namespace = "monitoring"
  }
  depends_on = [module.eks, helm_release.prometheus]
}

output "prometheus_pushgateway_external_lb" {
  value = data.kubernetes_service.prometheus_pushgateway_external.status[0].load_balancer[0].ingress[0].hostname
}

resource "null_resource" "scp_python_script" {

provisioner "file" {
  source      = var.python_script  # Локальный путь к папке
  destination = "/home/ubuntu/python_resource_monitor"  # Путь на удаленной машине
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)  # Приватный ключ для подключения
    host        = aws_instance.nginx_filebeat.public_ip  # IP удаленной машины
  }
}


  provisioner "remote-exec" {
    inline = [
      "echo 'Installing dependencies for Python script...'",
      "sudo bash /home/ubuntu/python_resource_monitor/prepeare.sh",
      "python3 /home/ubuntu/python_resource_monitor/monitor.py --pushgateway-url http://${data.kubernetes_service.prometheus_pushgateway_external.status[0].load_balancer[0].ingress[0].hostname}:9091 &"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)  # Путь к приватному ключу
      host        = aws_instance.nginx_filebeat.public_ip
    }
  }

  depends_on = [aws_instance.nginx_filebeat]  # Убедитесь, что сервис Push Gateway уже доступен
  
}
