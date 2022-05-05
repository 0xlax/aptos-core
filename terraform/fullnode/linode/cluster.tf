resource "linode_lke_cluster" "aptos" {
  label = "aptos-${terraform.workspace}"
  region = "us-central"
  k8s_version = "1.23"
  tags = [ "fullnodes" ]

  pool {
      type = var.machine_type
      count = var.num_fullnodes

  }

}
output "kubeconfig" {
  description = "Linode kubeconfig."
  value = linode_lke_cluster.aptos.kubeconfig
  sensitive   = true
}

resource "local_file" "kubeconfig" {
  content = base64decode(linode_lke_cluster.aptos.kubeconfig)
  filename = "${path.module}/linode_kubeconfig.yml"
}
