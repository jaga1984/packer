packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/vmware"
    }
  }
}

source "vmware-iso" "ubuntu" {
  iso_url = "file:///home/jgarcia/Downloads/ubuntu-22.04.5-live-server-amd64.iso"
  iso_checksum = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  
  vm_name = "ubuntu-server"
  guest_os_type = "ubuntu64Guest"
  
  cpus = 2
  memory = 2048
  disk_size = 20000
  
  network_adapter_type = "vmxnet3"
  
  # Boot and Shutdown Configuration
  boot_wait          = "3s"
  boot_command       = [  "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"]
   
  
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout = "30m"
  
  shutdown_command = "sudo shutdown -P now"
  
  vmx_data = {
    "virtualhw.version"                = "19"
    "cpuid.coresPerSocket" = "1"
    "mks.enable3d"                     = "FALSE"
    "svga.vramSize"                    = "134217728"
    "ide1:0.present"                   = "TRUE"
    "ide1:0.deviceType"                = "cdrom-raw"
    "ide1:0.startConnected"            = "FALSE"
    "ide1:0.clientDevice"              = "TRUE"
    "ethernet0.present"                = "TRUE"
    "ethernet0.connectionType"         = "nat"
    "ethernet0.virtualDev"             = "vmxnet3"
    "ethernet0.addressType"            = "generated"
    "RemoteDisplay.vnc.enabled"        = "FALSE"
    "vhv.enable"                       = "FALSE"
  }
}

build {
  sources = ["source.vmware-iso.ubuntu"]
  
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl wget git"
    ]
  }
}