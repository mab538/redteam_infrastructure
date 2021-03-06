# DigitalOcean Phishing Redirector (burnable)

resource "digitalocean_droplet" "phishing_rdr" {
    image = "ubuntu-20-04-x64"
    name = var.domain_rdir
    region = var.region
    size = "s-1vcpu-1gb"
    private_networking = true
    ssh_keys = [
        digitalocean_ssh_key.terraform.id
    ]

    connection {
        host = self.ipv4_address
        user = "root"
        type = "ssh"
        private_key = file(var.pvt_key)
        timeout = "2m"
    }

    provisioner "remote-exec" {
        inline = [
            # postfix
            "export DEBIAN_FRONTEND=noninteractive; apt update && apt-get -y -qq install socat postfix opendkim opendkim-tools certbot",      
            "echo ${var.domain_rdir} > /etc/mailname",
            "echo ${digitalocean_droplet.phishing_rdr.ipv4_address} ${var.domain_rdir} > /etc/hosts",
            "postconf -e myhostname=${var.domain_rdir}",
            "postconf -e milter_protocol=2",
            "postconf -e milter_default_action=accept",
            "postconf -e smtpd_milters=inet:localhost:12345",
            "postconf -e non_smtpd_milters=inet:localhost:12345",
            "postconf -e mydestination=\"${var.domain_rdir}, $myhostname, localhost.localdomain, localhost\"",
            "postconf -e mynetworks=\"127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 ${digitalocean_droplet.phishing.ipv4_address}\"",

            # dkim
            "mkdir -p /etc/opendkim/keys/${var.domain_rdir}",
            "cd /etc/opendkim/keys/${var.domain_rdir}; opendkim-genkey -t -s mail -d ${var.domain_rdir} && tr -d \"\\n\\t\\\" \" < mail.txt | cut -d\"(\" -f2 | cut -d \")\" -f1 > /root/dkim.txt; sudo chown opendkim:opendkim mail.private",
            "echo mail._domainkey.${var.domain_rdir} ${var.domain_rdir}:mail:/etc/opendkim/keys/${var.domain_rdir}/mail.private > /etc/opendkim/KeyTable",
            "echo *@${var.domain_rdir} mail._domainkey.${var.domain_rdir} > /etc/opendkim/SigningTable",
            "echo \"SOCKET=\"inet:12345@localhost\"\" >> /etc/default/opendkim",
            "echo ${digitalocean_droplet.phishing.ipv4_address} > /etc/opendkim/TrustedHosts",
            "echo *.${var.domain_rdir} >> /etc/opendkim/TrustedHosts",     
            "echo localhost >> /etc/opendkim/TrustedHosts",     
            "echo 127.0.0.1 >> /etc/opendkim/TrustedHosts",     
            "echo \"@reboot root socat TCP4-LISTEN:80,fork TCP4:${digitalocean_droplet.phishing.ipv4_address}:80\" >> /etc/cron.d/mdadm",
            "echo \"@reboot root socat TCP4-LISTEN:443,fork TCP4:${digitalocean_droplet.phishing.ipv4_address}:443\" >> /etc/cron.d/mdadm"
        ]
    }

    provisioner "local-exec" {
        command = "echo ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no root@${digitalocean_droplet.phishing_rdr.ipv4_address} cat /root/dkim.txt >> finalize.sh"
    }

    provisioner "file" {
        source = "./configs/header_checks"
        destination = "/etc/postfix/header_checks"
    }

    provisioner "file" {
        source = "./configs/master.cf"
        destination = "/etc/postfix/master.cf"
    }

    provisioner "file" {
        source = "./configs/opendkim.conf"
        destination = "/etc/opendkim.conf"
    }

  provisioner "remote-exec" {
      inline = [
          "postmap /etc/postfix/header_checks",
          "postfix reload",
          "service postfix restart; service opendkim restart",
          "shutdown -r"
      ]
  }
}