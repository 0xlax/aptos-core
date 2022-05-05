provider "kubernetes" {
    config_path = local_file.kubeconfig.filename
  
}


resource "kubernetes_namespace" "aptos" {
  metadata {
    name = var.k8s_namespace
  }
}



provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}




resource "helm_release" "fullnode" {
  count            = var.num_fullnodes
  name             = "${terraform.workspace}${count.index}"
  chart            = "${path.module}/../../helm/fullnode"
  max_history      = 100
  wait             = false
  namespace        = var.k8s_namespace
  create_namespace = true

  values = [
    jsonencode({
      chain = {
        era  = var.era
      }
      image = {
        tag = var.image_tag
      }
      nodeSelector = {
        "lks.linode.com/node-pool" = linode_lke_cluster.aptos.pool[0]
      }
      storageClass = {
          class = "do-block-storage"
      }
      service = {
        type = "LoadBalancer"
      }
      storage = {
        size = "100Gi"
      }
    }),
    jsonencode(var.fullnode_helm_values),
    jsonencode(var.fullnode_helm_values_list == {} ? {} : var.fullnode_helm_values_list[count.index]),
  ]

  set {
    name  = "timestamp"
    value = var.helm_force_update ? timestamp() : ""
  }
}