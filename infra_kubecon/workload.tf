resource "null_resource" "workload" {
  triggers = {
    filehash = sha256(join(",", flatten([
      for filename in fileset("${path.module}/../workloads_kubecon", "**") : filesha256(abspath("${path.module}/../workloads_kubecon/${filename}"))
      ]
    )))
  }
  provisioner "local-exec" {
    command = "make -C ${path.module}/../workloads_kubecon install"
    environment = {
      KUBECONFIG = abspath(local_file.kubeconfig.filename)
    }
  }
}