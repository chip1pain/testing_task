resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "prometheus"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  create_namespace = true

  set {
    name  = "server.global.scrape_interval"
    value = "30s" # Увеличиваем интервал для снижения нагрузки
  }
  set {
    name  = "server.resources.requests.memory"
    value = "512Mi"
  }
  set {
    name  = "server.resources.requests.cpu"
    value = "200m"
  }
  set {
    name  = "server.resources.limits.memory"
    value = "1024Mi"
  }
  set {
    name  = "server.resources.limits.cpu"
    value = "400m"
  }
  set {
    name  = "server.service.type"
    value = "ClusterIP" # Основной сервис для внутренней связи
  }

}


resource "kubernetes_service" "prometheus_pushgateway_external" {
  metadata {
    name      = "prometheus-pushgateway-external"
    namespace = "monitoring"
  }

  spec {
    type = "LoadBalancer"
    
    port {
      protocol   = "TCP"
      port       = 9091          # Порт для Pushgateway
      target_port = 9091         # Порт, на котором работает Pushgateway
    }

    selector = {
        "app.kubernetes.io/instance" = "prometheus"
        "app.kubernetes.io/name" = "prometheus-pushgateway"
    }

  }
  depends_on = [module.eks, helm_release.prometheus]
}
