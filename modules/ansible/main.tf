locals {
  ssh_user = "ubuntu"
  ssh_folder = "./.ssh"
  ssh_private_key_file = "${local.ssh_folder}/id_rsa"
  inventory_file = "./inventory.ini"
}

data "template_file" "inventory" {
  template = file("modules/ansible/templates/${local.inventory_file}.tmpl")

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
    working_dir = "./modules/ansible"
    command = <<EOT
      mkdir ${local.ssh_folder}
      echo '${var.app_ssh_public_key_pem}' > ${local.ssh_private_key_file}.pub
      echo '${var.app_ssh_private_key_pem}' > ${local.ssh_private_key_file}
      chmod 600 ${local.ssh_private_key_file}.pub
      chmod 600 ${local.ssh_private_key_file}
      echo '${data.template_file.inventory.rendered}' > ${local.inventory_file}
      ansible-playbook -i ${local.inventory_file} playbook.yml
    EOT
  }
}