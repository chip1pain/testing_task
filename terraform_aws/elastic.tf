data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}


resource "helm_release" "elasticsearch" {
  name             = "elasticsearch"
  chart            = "elasticsearch"
  namespace        = "elastic-stack"
  repository       = "https://helm.elastic.co"
  create_namespace = true

  set {
    name  = "clusterName"
    value = "elasticsearch"
  }
  set {
    name  = "esJavaOpts"
    value = "-Xms1g -Xmx1g"
  }
  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }
  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }
  set {
    name  = "resources.limits.cpu"
    value = "1"
  }
  set {
    name  = "resources.limits.memory"
    value = "2Gi"
  }
  set {
    name  = "networkHost"
    value = "0.0.0.0"
  }
  set {
    name  = "secret.enabled"
    value = "true"
  }
  set {
    name  = "replicas"
    value = "1"
  }
  set {
    name  = "roles"
    value = "{master, data, ingest}"
  }
  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = "gp2"
  }
  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = "10Gi"
  }
}

resource "helm_release" "kibana" {
  name             = "kibana"
  chart            = "kibana"
  namespace        = "elastic-stack"
  repository       = "https://helm.elastic.co"
  depends_on = [
    helm_release.elasticsearch
  ]

  set {
    name  = "clusterName"
    value = "elasticsearch"
  }
  set {
    name  = "replicas"
    value = "1"
  }
  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }
  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }
  set {
    name  = "resources.limits.cpu"
    value = "1"
  }
  set {
    name  = "resources.limits.memory"
    value = "1Gi"
  }
  set {
    name  = "elasticsearch.hosts[0]"
    value = "https://elasticsearch-master:9200"
  }
  set {
    name  = "service.type"
    value = "NodePort"
  }
  set {
    name  = "secret.enabled"
    value = "true"
  }
}


resource "kubernetes_config_map" "logstash_config" {
  metadata {
    name      = "logstash-config"
    namespace = "elastic-stack"
  }
  depends_on = [
    helm_release.elasticsearch
  ]
  data = {
    "logstash.conf" = <<EOT
input {
  beats {
    host => "0.0.0.0"
    port => 5044
    ssl => false
    client_inactivity_timeout => 1200
  }
}

filter {
  grok {
    match => {
      "message" => "%%{IPV4:client_ip} - %%{DATA:remote_user} \[%%{HTTPDATE:timestamp}\] \"%%{WORD:request_method} %%{URIPATH:request_path} HTTP/%%{NUMBER:http_version}\" %%{NUMBER:response_code} %%{NUMBER:bytes_sent} \"%%{DATA:referrer}\" \"%%{DATA:user_agent}\""
    }
  }
}
output {
  elasticsearch {
    hosts => ["https://elasticsearch-master:9200"]
    index => "filebeat-%%{+yyyy.MM.dd}"
    ssl => true
    ssl_certificate_verification => true
    cacert => "/usr/share/logstash/config/certs/ca.crt"
    user => "elastic"
    password => "$${ELASTIC_PASSWORD}"
  }
}
EOT
  }
}



resource "kubernetes_config_map" "logstash_yml" {
  metadata {
    name      = "logstash-yml"
    namespace = "elastic-stack"
  }
  depends_on = [
    helm_release.elasticsearch
  ]

  data = {
    "logstash.yml" = <<EOT
http.host: "0.0.0.0"
xpack.monitoring.enabled: true
xpack.monitoring.elasticsearch.hosts: ["https://elasticsearch-master:9200"]
xpack.monitoring.elasticsearch.username: "elastic"
xpack.monitoring.elasticsearch.password: "$${ELASTIC_PASSWORD}"
xpack.monitoring.elasticsearch.ssl.certificate_authority: "/usr/share/logstash/config/certs/ca.crt"
EOT
  }
}

resource "helm_release" "logstash" {
  name             = "logstash"
  chart            = "logstash"
  namespace        = "elastic-stack"
  repository       = "https://helm.elastic.co"
  create_namespace = true
  depends_on = [kubernetes_config_map.logstash_yml, kubernetes_config_map.logstash_config]


  set {
    name  = "replicas"
    value = "1"
  }
  set {
    name  = "resources.requests.cpu"
    value = "500m"
  }
  set {
    name  = "resources.requests.memory"
    value = "1Gi"
  }
  set {
    name  = "resources.limits.cpu"
    value = "1"
  }
  set {
    name  = "resources.limits.memory"
    value = "1.2Gi"
  }
  set {
    name  = "persistence.enabled"
    value = "false"
  }
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "service.ports[0].name"
    value = "beats"
  }
  set {
    name  = "service.ports[0].port"
    value = "5044"
  }
  set {
    name  = "service.ports[0].targetPort"
    value = "5044"
  }
  set {
    name  = "extraVolumes[0].name"
    value = "logstash-config"
  }
  set {
    name  = "extraVolumes[0].configMap.name"
    value = "logstash-config"
  }
  set {
    name  = "extraVolumeMounts[0].name"
    value = "logstash-config"
  }
  set {
    name  = "extraVolumeMounts[0].mountPath"
    value = "/usr/share/logstash/pipeline/logstash.conf"
  }
  set {
    name  = "extraVolumeMounts[0].subPath"
    value = "logstash.conf"
  }
  set {
    name  = "extraVolumes[1].name"
    value = "logstash-yml"
  }
  set {
    name  = "extraVolumes[1].configMap.name"
    value = "logstash-yml"
  }
  set {
    name  = "extraVolumeMounts[1].name"
    value = "logstash-yml"
  }
  set {
    name  = "extraVolumeMounts[1].mountPath"
    value = "/usr/share/logstash/config/logstash.yml"
  }
  set {
    name  = "extraVolumeMounts[1].subPath"
    value = "logstash.yml"
  }
  set {
    name  = "extraVolumes[2].name"
    value = "elasticsearch-certs"
  }
  set {
    name  = "extraVolumes[2].secret.secretName"
    value = "elasticsearch-master-certs"
  }
  set {
    name  = "extraVolumeMounts[2].name"
    value = "elasticsearch-certs"
  }
  set {
    name  = "extraVolumeMounts[2].mountPath"
    value = "/usr/share/logstash/config/certs"
  }
  set {
    name  = "extraVolumeMounts[2].readOnly"
    value = "true"
  }
  set {
    name  = "extraEnvs[0].name"
    value = "ELASTIC_PASSWORD"
  }
  set {
    name  = "extraEnvs[0].valueFrom.secretKeyRef.name"
    value = "elasticsearch-master-credentials"
  }
  set {
    name  = "extraEnvs[0].valueFrom.secretKeyRef.key"
    value = "password"
  }
}

data "kubernetes_service" "logstashUrl" {
  metadata {
    name      = "logstash-logstash"
    namespace = "elastic-stack"
  }

  depends_on = [helm_release.logstash]
}

