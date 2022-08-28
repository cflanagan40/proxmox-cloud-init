#--------------------------------------------
# Proxmox Provider Variables
# Used to connect to to proxmox
#---------------------------------------------

variable vm_name {
  type = string
}

variable cpu {
  type = number
  default = 4
}

variable memory {
  type = number
  default = 8192
}

variable datacenter_name {
  type = string
  default = "pve"
}

variable template_name {
  type = string
  default = "ubuntu-2004-cloudinit-template"
} 

# ---------------------------------------------------------------------------------------------------------------------
# CLOUD INIT VARIABLES
# Variables used for generation of metadata and userdata.
# ---------------------------------------------------------------------------------------------------------------------

variable username {
  type = string
  default = "ansible"
}

variable ssh_public_key {
  type        = string
  description = "Location of SSH public key."
  default = "~/.ssh/id_rsa.pub"
}

variable packages {
  type    = list
  default = ["jq","qemu-guest-agent"]
}

variable os_type {
  type = string
  default = "cloud-init"
}
