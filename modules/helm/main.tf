#helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
#helm repo update


resource "helm_release" "fantastic-app" {
  name       = "fantastic-app"
  repository = "https://victor-ocanto.github.io/fantastic-app-demo"
  chart      = "fantastic-app"
  namespace  = "apps"
  create_namespace = true
  timeout = 820
  values = [
    <<EOF
db:
  host: "${var.db_host}"
  name: "${var.db_name}"
  user: "${var.db_admin_username}"
  password: "${var.db_admin_password}"

service:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${var.certificate_arn}"  
EOF
  ]
} 

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
}
