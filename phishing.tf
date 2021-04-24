# create a phishing droplet
resource "digitalocean_droplet" "phishing" {
  image = "ubuntu-20-04-x64"
  name = "phishing"
  region = var.region
  size   = "s-1vcpu-1gb"
  ssh_keys = ["${digitalocean_ssh_key.terraform.id}"]

  connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
    }

  provisioner "remote-exec" {
    inline = [
        "export DEBIAN_FRONTEND=noninteractive; apt update && apt-get -y install zip",
        "mkdir -p /opt/gophish; cd /opt/gophish; wget ${var.gophish_zip_url} -O gophish.zip && unzip gophish.zip; chmod +x gophish;",
        "echo \"@reboot root cd /opt/gophish; ./gophish\" >> /etc/cron.d/mdadm",
    ]
  }

  provisioner "file" {
      source = "./configs/config.json"
      destination = "/opt/gophish/config.json"
  }

  provisioner "local-exec" {
        command = "echo ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@${digitalocean_droplet.phishing.ipv4_address} certbot certonly --standalone -d ${var.phishing_subdomain1}.${var.domain_rdir} --register-unsafely-without-email --agree-tos >> finalize.sh"
  }

  provisioner "local-exec" {
      command = "echo ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@${digitalocean_droplet.phishing.ipv4_address} cp /etc/letsencrypt/live/${var.phishing_subdomain1}.${var.domain_rdir}/privkey.pem /opt/gophish/domain.key >> finalize.sh"
  }

  provisioner "local-exec" {
      command = "echo ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@${digitalocean_droplet.phishing.ipv4_address} cp /etc/letsencrypt/live/${var.phishing_subdomain1}.${var.domain_rdir}/fullchain.pem /opt/gophish/domain.crt >> finalize.sh"
  }

  provisioner "local-exec" {
        command = "echo ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@${digitalocean_droplet.phishing.ipv4_address} shutdown -r >> finalize.sh"
  }

  provisioner "local-exec" {
        command = "chmod +x finalize.sh"
  }

}