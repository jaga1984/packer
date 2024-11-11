packer {
  required_plugins {
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1.0.8"
    }
   windows-update = {
      version = "0.14.1"
      source = "github.com/rgl/windows-update"
    }
  }
}

source "vmware-iso" "windows_server" {
  # VM Basic Configuration
  vm_name              = "WindowsServer2022"
  display_name         = "Windows Server 2022 Standard"
  guest_os_type        = "windows2019srv-64"
  version             = "19"
  
  # VM Hardware Configuration
  memory              = 4096
  cpus                = 2
  disk_adapter_type   = "lsisas1068"
  disk_size           = 102400
  disk_type_id        = "0"  # 0 = Thin Provision
  network_adapter_type = "vmxnet3"
  
  # ISO Configuration
  iso_url             = "file:///home/jgarcia/Downloads/SERVER_EVAL_x64FRE_en-us.iso"
  iso_checksum        = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  
  # VMware Workstation specific settings
  vmx_data = {
    "virtualhw.version"                = "19"
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

  # Windows Configuration
  communicator        = "winrm"
  winrm_username      = "Administrator"
  winrm_password      = "Asdf1234$"  # Change this!
  winrm_timeout      = "15m"
  winrm_insecure     = true
  
  # Boot and Shutdown Configuration
  boot_wait          = "3s"
  boot_command       = ["<enter>"]
  shutdown_command   = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout   = "15m"
    
  # Answer File Configuration
  floppy_files       = [
    "./answer_files/autounattend.xml",
    "./scripts/winrmConfig.bat",
    #"./scripts/disable-winrm.ps1",
    #"./scripts/enable-winrm.ps1",
    #"./scripts/microsoft-updates.ps1"
  ]
}

build {
  sources = ["source.vmware-iso.windows_server"]
  
  #Initial Setup
  provisioner "powershell" {
    script = "./scripts/initial-setup.ps1"
  }
  
  # Windows Updates
  #provisioner "windows-update" {
  #  search_criteria = "IsInstalled=0"
  #  filters = [
  #    "exclude:$_.Title -like '*Preview*'",
  #    "include:$true"
  #  ]
  #  update_limit = 25
  #}
  
  # Install Features
  #provisioner "powershell" {
  #  inline = [
  #    "Install-WindowsFeature -Name Web-Server -IncludeManagementTools",
  #    "Install-WindowsFeature -Name NET-Framework-45-Features"
  #  ]
  #}
  
  # System Configuration
  #provisioner "powershell" {
  #  script = "./scripts/system-config.ps1"
  #}
  
  # Cleanup
  #provisioner "powershell" {
  #  script = "./scripts/cleanup.ps1"
  #}
}
