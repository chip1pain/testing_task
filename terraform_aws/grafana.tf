resource "helm_release" "grafana" {
  name             = "grafana"
  chart            = "grafana"
  namespace        = "monitoring"
  repository       = "https://grafana.github.io/helm-charts"
  create_namespace = true

  set {
    name  = "adminPassword"
    value = "admin123" # Замените на более безопасный пароль
  }

  # Передаем настройки для datasources через values
  values = [
    <<EOF
    datasources:
      default:
        name: "Prometheus"
        type: "prometheus"
        url: "http://prometheus-server.monitoring.svc.cluster.local"
        access: "proxy"
        isDefault: true
    EOF
  ]

  # Конфигурация для типа сервиса (NodePort)
  set {
    name  = "service.type"
    value = "NodePort" # Доступ извне через NodePort
  }

  set {
    name  = "service.nodePort"
    value = "32000" # Указываем фиксированный порт
  }

  # Конфигурация для ресурсов
  set {
    name  = "resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.limits.memory"
    value = "1024Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "200m"
  }
}
