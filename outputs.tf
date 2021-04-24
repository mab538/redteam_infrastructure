output "outputs" {
    value = [
        "## IP Addresses:",
        "   phishing          ${digitalocean_droplet.phishing.name} - ${digitalocean_droplet.phishing.ipv4_address}",
        "   phishing_rdr      ${digitalocean_droplet.phishing_rdr.name} - ${digitalocean_droplet.phishing_rdr.ipv4_address}",
        "## DNS Records:",
        "mail.${var.domain_rdir} - ${digitalocean_record.phishing_rdr_mail_1a.value}",
        "${var.phishing_subdomain1}.${var.domain_rdir} - ${digitalocean_record.phishing_rdr_a1.value}",
        "${var.phishing_subdomain2}.${var.domain_rdir} - ${digitalocean_record.phishing_rdr_a2.value}",
        "## URLs:",
        "    GoPhish: https://${var.phishing_subdomain1}.${var.domain_rdir}:3333",
        "To finalise the infrastructure, run ./finalize.sh and update the DNS DKIM in DigitalOcean for ${var.domain_rdir} which the script will provide."
    ]
}