packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/vmware"
    }
  }
}

variable "cpu_cores" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "disk_size" {
  type    = string
  default = "40960"
}

source "vmware-iso" "ubuntu" {
  // VM Settings
  vm_name              = "ubuntu-2204-server"
  display_name         = "Ubuntu 22.04 Server"
  guest_os_type        = "ubuntu64Guest"
  
  // Hardware Settings
  cpus                 = var.cpu_cores
  memory              = var.memory
  disk_size            = var.disk_size
  disk_adapter_type   = "pvscsi"
  network_adapter_type = "vmxnet3"
  
  // ISO Settings
  iso_url          = "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum     = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
  
  // Boot and Provisioning Settings
  http_directory    = "http"
  boot_wait        = "5s"
  boot_command     = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"
  ]
  
  // SSH Settings
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "30m"
  ssh_port         = 22
  
  // Shutdown Settings
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  
  // VMware Workstation Settings
  vmx_data = {
    "virtualHW.version"              = "19"
    "mks.enable3d"                   = "TRUE"
    "pciBridge0.present"             = "TRUE"
    "pciBridge4.present"             = "TRUE"
    "pciBridge4.virtualDev"          = "pcieRootPort"
    "pciBridge4.functions"           = "8"
    "pciBridge5.present"             = "TRUE"
    "pciBridge5.virtualDev"          = "pcieRootPort"
    "pciBridge5.functions"           = "8"
    "pciBridge6.present"             = "TRUE"
    "pciBridge6.virtualDev"          = "pcieRootPort"
    "pciBridge6.functions"           = "8"
    "pciBridge7.present"             = "TRUE"
    "pciBridge7.virtualDev"          = "pcieRootPort"
    "pciBridge7.functions"           = "8"
    "ethernet0.pciSlotNumber"        = "32"
    "ethernet0.present"              = "TRUE"
    "ethernet0.virtualDev"           = "vmxnet3"
    "ethernet0.connectionType"       = "nat"
    "ethernet0.addressType"          = "generated"
    "ethernet0.wakeonpcktrcv"        = "FALSE"
    "scsi0.virtualDev"              = "pvscsi"
    "scsi0.present"                 = "TRUE"
    "scsi0:0.present"               = "TRUE"
    "scsi0:0.fileName"              = "disk.vmdk"
    "vmci0.present"                 = "TRUE"
    "hpet0.present"                 = "TRUE"
    "tools.syncTime"                = "TRUE"
    "time.synchronize.continue"      = "TRUE"
    "time.synchronize.restore"       = "TRUE"
    "time.synchronize.resume.disk"   = "TRUE"
    "time.synchronize.shrink"        = "TRUE"
    "time.synchronize.tools.startup" = "TRUE"
    "time.synchronize.tools.enable"  = "TRUE"
    "time.synchronize.resume.host"   = "TRUE"
  }
}

build {
  sources = ["source.vmware-iso.ubuntu"]

  provisioner "shell" {
    inline = [
      // System Updates
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      
      // Install Essential Packages
      "sudo apt-get install -y curl wget git build-essential",
      "sudo apt-get install -y open-vm-tools",
      "sudo apt-get install -y cloud-init",
      
      // Security Packages
      "sudo apt-get install -y unattended-upgrades apt-listchanges",
      "sudo dpkg-reconfigure -f noninteractive unattended-upgrades",
      
      // Network Tools
      "sudo apt-get install -y net-tools nmap",
      
      // System Monitoring
      "sudo apt-get install -y htop iotop",
      
      // Configure SSH
      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sudo systemctl restart sshd",
      
      // Cleanup
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      
      // Clear Machine-ID
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id"
    ]
  }
}