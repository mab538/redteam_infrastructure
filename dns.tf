# Phishing Redirector Records
resource "digitalocean_record" "phishing_rdr_a0" {
    domain = var.domain_rdir
    name = "@"
    value = digitalocean_droplet.phishing_rdr.ipv4_address
    type = "A"
    ttl = 60
}

# This is the gophish interface on port 3333
resource "digitalocean_record" "phishing_rdr_a1" {
    domain = var.domain_rdir
    name = var.phishing_subdomain1
    value = digitalocean_droplet.phishing.ipv4_address
    type = "A"
    ttl = 60
}

# This is the HTTP/HTTPS redirect to the gophish instance
resource "digitalocean_record" "phishing_rdr_a2" {
    domain = var.domain_rdir
    name = var.phishing_subdomain2
    value = digitalocean_droplet.phishing_rdr.ipv4_address
    type = "A"
    ttl = 60
}


# SMTP Relay 1
resource "digitalocean_record" "phishing_rdr_mail_1a" {
    domain = var.domain_rdir
    name = "mail"
    value = digitalocean_droplet.phishing_rdr.ipv4_address
    type = "A"
    ttl = 60
}

## mail relay MX
resource "digitalocean_record" "phishing_rdr_mail_mx" {
    domain = var.domain_rdir
    name = "@"
    value = "mail.${var.domain_rdir}."
    type = "MX"
    priority = 5
    ttl = 60
}

## mail relay TXT SPF
resource "digitalocean_record" "phishing-rdr-mail-spf" {
    domain = var.domain_rdir
    name   = "@"
    value  = "v=spf1 ip4:${digitalocean_droplet.phishing_rdr.ipv4_address} include:_spf.google.com ~all"
    type   = "TXT"
    ttl    = 60
}

## mail relay TXT DKIM placeholder
resource "digitalocean_record" "phishing_rdr_mail_dkim" {
    domain = var.domain_rdir
    name   = "mail._domainkey"
    value  = "I am DKIM, but change me with the DKIM provided by finalize.sh"
    type   = "TXT"
    ttl    = 60
}

## mail relay TXT DMARC
resource "digitalocean_record" "phishing_rdr_mail_dmarc" {
    domain = var.domain_rdir
    name = "_dmarc"
    value = "v=DMARC1; p=reject"
    type = "TXT"
    ttl = 60
}