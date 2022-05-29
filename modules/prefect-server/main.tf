resource "helm_release" "prefect-server" {
  name      = "prefect-server"
  namespace = var.namespace

  dependency_update = true
  repository = "https://prefecthq.github.io/server/"
  chart = "prefect-server"
  version = "2022.04.14"

  set {
    name = "jobs.createTenant.enabled"
    value = var.create_tenant_enabled
  }

  set {
    name  = "agent.enabled"
    value = var.agent_enabled
  }

  set {
    name  = "agent.image.name"
    value = var.agent_image_name
  }

  set {
    name  = "agent.image.tag"
    value = var.agent_image_tag
  }

  set {
    name  = "agent.image.pullPolicy"
    value = var.agent_image_pull_policy
  }

  set {
    name  = "prefectVersionTag"
    value = var.prefect_version_tag
  }

  set {
    name  = "postgresql.postgresqlDatabase"
    value = var.postgresql_database
  }

  set {
    name  = "postgresql.postgresqlUsername"
    value = var.postgresql_username
  }

  set {
    name  = "postgresql.existingSecret"
    value = var.postgresql_existing_secret
  }

  set {
    name  = "postgresql.servicePort"
    value = var.postgresql_service_port
  }

  set {
    name  = "postgresql.externalHostname"
    value = var.postgresql_external_hostname
  }

  set {
    name  = "postgresql.useSubchart"
    value = var.postgresql_use_subchart
  }

  set {
    name  = "postgresql.persistence.enabled"
    value = var.postgresql_persistence_enabled
  }

  set {
    name  = "postgresql.persistence.size"
    value = var.postgresql_persistence_size
  }

  set {
    name  = "postgresql.initdbUser"
    value = var.postgresql_init_user
  }

  set {
    name = "ui.apolloApiUrl"
    value = var.graphql_url
  }

  set {
    name = "apollo.service.type"
    value = "ClusterIP"
  }

  set {
    name = "ui.service.type"
    value = var.service_type
  }

  set {
    name = "serviceAccount.name"
    value = var.service_account_name
  }

  values = [
    yamlencode({
      "annotations" = var.annotations
    }),

    yamlencode({
      "agent" = {
        "prefectLabels" = var.agent_prefect_labels
      }
    }),
  ]
}

resource "kubernetes_cluster_role_binding" "seldon_prefect_crb" {
  count = var.seldon_manager_cluster_role_name != "" ? 1 : 0

  metadata {
    name = "prefect-seldon-rolebinding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = var.seldon_manager_cluster_role_name
  }
  subject {
    kind = "ServiceAccount"
    name = var.service_account_name
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "feast_spark_operator_prefect_crb" {
  count = var.feast_spark_operator_cluster_role_name != "" ? 1 : 0

  metadata {
    name = "prefect-feast-spark-operator"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = var.feast_spark_operator_cluster_role_name
  }
  subject {
    kind = "ServiceAccount"
    name = var.service_account_name
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "omi_prefect_image_pull_secret" {
  metadata {
    name = "regcred"
    namespace = var.namespace
  }

   data = {
    ".dockerconfigjson" = <<-DOCKER
          {
            "auths": {
              "https://index.docker.io/v1/": {
                "auth": "${var.prefect_pull_image_auth}"
              }
            }
          }
          DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}
