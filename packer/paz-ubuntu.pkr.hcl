variable "YC_FOLDER_ID" {
  type = string
  default = env("YC_FOLDER_ID")
}

variable "YC_ZONE" {
  type = string
  default = env("YC_ZONE")
}

variable "YC_SUBNET_ID" {
  type = string
  default = env("YC_SUBNET_ID")
}

variable "TF_VER" {
  type = string
  default = "1.1.9"
}

variable "KCTL_VER" {
  type = string
  default = "1.23.0"
}

variable "HELM_VER" {
  type = string
  default = "3.9.0"
}

variable "GRPCURL_VER" {
  type = string
  default = "1.8.6"
}

variable "GOLANG_VER" {
  type = string
  default = "1.17.2"
}

variable "PULUMI_VER" {
  type = string
  default = "3.33.2"
}

source "yandex" "debian_docker" {
  folder_id           = "${var.YC_FOLDER_ID}"
  source_image_family = "ubuntu-2004-lts"
  ssh_username        = "ubuntu"
  use_ipv4_nat        = "true"
  image_description   = "my custom debian with docker"
  image_family        = "my-images"
  image_name          = "ubuntu-2004l-docker"
  subnet_id           = "${var.YC_SUBNET_ID}"
  disk_type           = "network-hdd"
  zone                = "${var.YC_ZONE}"
}

build {
  sources = ["source.yandex.debian_docker"]

  provisioner "shell" {
    inline = [
      # Global Ubuntu things
      "sudo apt-get update",
      #"echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      #"sudo apt-get install -y unzip",

      # Yandex Cloud CLI tool
      "curl --silent --remote-name https://storage.yandexcloud.net/yandexcloud-yc/install.sh",
      "chmod u+x install.sh",
      "sudo ./install.sh -a -i /usr/local/ 2>/dev/null",
      "rm -rf install.sh",
      "sudo sed -i '$ a source /usr/local/completion.bash.inc' /etc/profile",
  
      # Docker
      "curl --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce containerd.io",
      "sudo usermod -aG docker $USER",
      "sudo chmod 666 /var/run/docker.sock",
      "sudo useradd -m -s /bin/bash -G docker yc-user",

      # Docker Artifacts
      "docker pull hello-world",
      "docker pull -q amazon/aws-cli",
      "docker pull -q golang:${var.GOLANG_VER}",

      # Other packages
      "sudo apt-get install -y htop tmux",

      # Clean
      "rm -rf .sudo_as_admin_successful",

      # Test - Check versions for installed components
      "echo '=== Tests Start ==='",
      "yc version",
      "docker version",
      "echo '=== Tests End ==='"
    ]
  }
}

