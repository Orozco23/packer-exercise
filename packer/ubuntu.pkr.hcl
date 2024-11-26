packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-nginx-nodejs"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-nginx-nodejs"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -",
      "sudo apt-get install -y nodejs nginx",
      "node -v",
      "sudo mkdir -p /var/www/nodejs_app",
      "sudo chown -R ubuntu:ubuntu /var/www",
      "git clone https://github.com/Orozco23/packer-exercise.git /var/www/nodejs_app",
      "cd /var/www/nodejs_app/nodejs-app/src",
      "sudo npm i",
      "sudo chown -R ubuntu:ubuntu /var/www/nodejs_app",
      "echo '[Unit]\nDescription=Node.js App\n[Service]\nExecStart=/usr/bin/node /var/www/nodejs_app/nodejs-app/src/app.js\nRestart=always\nUser=ubuntu\nEnvironment=PORT=3000\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/nodeapp.service",
      "sudo systemctl enable nodeapp",
      "sudo systemctl start nodeapp",
      "sudo cp /var/www/nodejs_app/nodejs-app/nginx.conf /etc/nginx/sites-available/nodejs_app",
      "sudo ln -s /etc/nginx/sites-available/node_app /etc/nginx/sites-enabled/",
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
  }
}
