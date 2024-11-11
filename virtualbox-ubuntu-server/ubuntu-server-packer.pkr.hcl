packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "ubuntu" {
  iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum     = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
  
  guest_os_type    = "Ubuntu_64"
  vm_name          = "ubuntu-server"
  
  cpus             = 2
  memory           = 2048
  disk_size        = 20000
  
  http_directory   = "http"
  boot_command     = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"
  ]
  
  ssh_username     = "ubuntu"
  ssh_password     = "ubuntu"
  ssh_timeout      = "30m"
  
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  
  guest_additions_path = "VBoxGuestAdditions_{{.Version}}.iso"
  guest_additions_mode = "upload"
  
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "2048"],
    ["modifyvm", "{{.Name}}", "--cpus", "2"],
    ["modifyvm", "{{.Name}}", "--vram", "32"],
    ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]
  ]
}

build {
  sources = ["source.virtualbox-iso.ubuntu"]
  
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl wget git build-essential",
      
      # Install VirtualBox Guest Additions
      "sudo apt-get install -y dkms",
      "sudo mkdir -p /mnt/vbox",
      "sudo mount -o loop /home/ubuntu/VBoxGuestAdditions_{{.Version}}.iso /mnt/vbox",
      "cd /mnt/vbox",
      "sudo sh ./VBoxLinuxAdditions.run || true",
      "cd /",
      "sudo umount /mnt/vbox",
      "rm -f /home/ubuntu/VBoxGuestAdditions_{{.Version}}.iso"
    ]
  }
}