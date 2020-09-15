locals {
  ssh_user = "ubuntu"
  ssh_private_key_file = "./.ssh/id_rsa"
  inventory_file = "./inventory.ini"
}

data "template_file" "inventory" {
  template = "./templates/inventory.ini.tmpl"

  vars = {
    app_hosts = join("\n", var.app_eip_list)
    migration_hosts = var.app_eip_list[0]

    ssh_user = local.ssh_user
    ssh_private_key_file = local.ssh_private_key_file

    db_host = var.db_host
    db_port = var.db_port
    db_name = var.db_name
    db_user = var.db_user
    db_password = var.db_password
    flyway_folder = var.flyway_folder
  }
}

resource "null_resource" "this" {

  provisioner "local-exec" {
    command = <<EOT
      mkdir ./.ssh
      echo '${var.app_ssh_public_key_pem}' > ${local.ssh_private_key_file}.pub
      echo '${var.app_ssh_private_key_pem}' > ${local.ssh_private_key_file}
      echo '${data.template_file.inventory.rendered}' > ${local.inventory_file}
      ansible-playbook -i ${local.inventory_file} playbook.yml
    EOT
  }
}