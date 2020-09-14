locals {
  ssh_user = "ubuntu"
  ssh_private_key_file = "./.ssh/id_rsa"
  inventory_file = "./inventory.ini"
}

data "template_file" "host" {
  count = length(var.app_eip_list)

  template = "./templates/host.tmpl"

  vars = {
    host = var.app_eip_list[count.index]
    ssh_user = local.ssh_user
    ssh_private_key_file = local.ssh_private_key_file
  }
}

data "template_file" "inventory" {
  template = "./templates/inventory.ini.tmpl"

  vars = {
    app_hosts = join("\n", data.template_file.host.*.rendered)
  }
}

resource "null_resource" "this" {

  provisioner "local-exec" {
    command = <<EOT
      mkdir ./.ssh
      echo '${var.app_ssh_public_key_pem}' > ${local.ssh_private_key_file}.pub
      echo '${var.app_ssh_private_key_pem}' > ${local.ssh_private_key_file}
      echo '${data.template_file.inventory.rendered}' > ${local.inventory_file}
      ansible-playbook -i ${local.inventory_file} install-app.yml
    EOT
  }
}