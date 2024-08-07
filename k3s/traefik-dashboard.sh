cat >> /var/lib/rancher/k3s/server/manifests/traefik-config.yaml << EOF
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    dashboard:
      enabled: true
    ports:
      traefik:
        expose: true # this is not recommended in production deployments, but I want to be able to see my dashboard locally
    logs:
      access:
        enabled: true
EOF
