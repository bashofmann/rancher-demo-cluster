resource "rancher2_cloud_credential" "kubecon_aws" {
  name = "kubecon-aws"
  amazonec2_credential_config {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
  }
}

resource "rancher2_machine_config_v2" "kubecon_demo_controlplane" {
  generate_name = "kubecon-demo-controlplane"
  amazonec2_config {
    ami            = data.aws_ami.sles.id
    region         = var.aws_region
    security_group = [aws_security_group.kubecon_demo.name]
    subnet_id      = aws_subnet.kubecon_demo_subnet.id
    vpc_id         = aws_vpc.kubecon_demo_vpc.id
    zone           = "b"
    instance_type  = "t3a.large"
    ssh_user       = "ec2-user"
  }
}

resource "rancher2_machine_config_v2" "kubecon_demo_worker" {
  generate_name = "kubecon-demo-worker"
  amazonec2_config {
    ami            = data.aws_ami.sles.id
    region         = var.aws_region
    security_group = [aws_security_group.kubecon_demo.name]
    subnet_id      = aws_subnet.kubecon_demo_subnet.id
    vpc_id         = aws_vpc.kubecon_demo_vpc.id
    zone           = "b"
    instance_type  = "t3a.xlarge"
    ssh_user       = "ec2-user"
  }
}

resource "rancher2_cluster_v2" "kubecon_demo" {
  name                         = "kubecon-demo"
  kubernetes_version           = "v1.21.12+rke2r2"
  cloud_credential_secret_name = rancher2_cloud_credential.kubecon_aws.id
  rke_config {
    machine_pools {
      name                         = "controlplane"
      cloud_credential_secret_name = rancher2_cloud_credential.kubecon_aws.id
      control_plane_role           = true
      etcd_role                    = true
      worker_role                  = false
      quantity                     = 3
      machine_config {
        kind = rancher2_machine_config_v2.kubecon_demo_controlplane.kind
        name = rancher2_machine_config_v2.kubecon_demo_controlplane.name
      }
    }
    machine_pools {
      name                         = "worker"
      cloud_credential_secret_name = rancher2_cloud_credential.kubecon_aws.id
      control_plane_role           = false
      etcd_role                    = false
      worker_role                  = true
      quantity                     = 5
      machine_config {
        kind = rancher2_machine_config_v2.kubecon_demo_worker.kind
        name = rancher2_machine_config_v2.kubecon_demo_worker.name
      }
    }
  }
}

resource "rancher2_cluster_sync" "sync" {
  cluster_id = rancher2_cluster_v2.kubecon_demo.cluster_v1_id
}

locals {
  worker_ips = toset([for node in rancher2_cluster_sync.sync.nodes : node.external_ip_address if contains(node.roles, "worker")])
}

resource "local_file" "kubeconfig" {
  content  = rancher2_cluster_sync.sync.kube_config
  filename = "${path.module}/kubeconfig"
}

data "rancher2_principal" "rancher_standard" {
  name = "RancherStandard"
  type = "group"
}

data "rancher2_role_template" "cluster_owner" {
  name = "Cluster Owner"
  context = "cluster"
}

resource "rancher2_cluster_role_template_binding" "rancher_standard" {
  name = "rancher-standard"
  cluster_id = rancher2_cluster_v2.kubecon_demo.id
  role_template_id = data.rancher2_role_template.cluster_owner.id
  group_principal_id = data.rancher2_principal.rancher_standard.id
}