terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.8.0"
    }
  }
}

/* Custom Cloud Init */
# Source the Cloud Init Config file
data "template_file" "cloud_init" {
  template  = file("${path.module}/templates/userdata.yaml")
  vars = {
    username       = var.username
    ssh_public_key = file(var.ssh_public_key)
    packages       = jsonencode(var.packages)
    hostname       = var.vm_name
  }
}

# Create a local copy of the file, to transfer to Proxmox
resource "local_file" "cloud_init" {
  content   = data.template_file.cloud_init.rendered
  filename  = "${path.module}/files/user_data_cloud_init_${var.vm_name}.cfg"
}

# Transfer the file to the Proxmox Host
resource "null_resource" "cloud_init" {
  connection {
    type    = "ssh"
    user    = "root"
    private_key = file("~/.ssh/id_rsa")
    host    = "192.168.1.222"
  }

  provisioner "file" {
    source       = local_file.cloud_init.filename
    destination  = "/var/lib/vz/snippets/cloud_init_${var.vm_name}.yml"
  }
}

/* Uses cloud-init options from Proxmox 5.2 */
resource "proxmox_vm_qemu" "vm" {

  depends_on = [
    null_resource.cloud_init
  ]

  name        = var.vm_name
  target_node = var.datacenter_name

  os_type = var.os_type

  clone = var.template_name

  bootdisk = "scsi0"
  cicustom = "user=local:snippets/cloud_init_${var.vm_name}.yml"
  ipconfig0 = "ip=dhcp"

  disk {
    storage = "local-thpl"
    type    = "scsi"
    size    = "120G"
  }
  cores   = var.cpu
  sockets = 1
  memory  = var.memory

  network {
    model  = "virtio"
    bridge = "vmbr1"
  }

  # Ignore changes to the network
  ## MAC address is generated on every apply, causing
  ## TF to think this needs to be rebuilt on every apply
  lifecycle {
     ignore_changes = [
       network
     ]
  }

  agent      = 1

}

output "default_ipv4_address" {
  value = proxmox_vm_qemu.vm.default_ipv4_address
}
