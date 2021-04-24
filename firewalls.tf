resource "digitalocean_firewall" "baseline" {
    name = "baseline"
    droplet_ids = [
        "${digitalocean_droplet.phishing.id}",
        "${digitalocean_droplet.phishing_rdr.id}"        
        ]

    inbound_rule {
            protocol = "tcp"
            port_range = "22"
            source_addresses = ["${var.operator_ip}"]
    }

    outbound_rule {
            protocol = "udp"
            port_range = "53"
            destination_addresses = ["0.0.0.0/0"]
    }   
}

resource "digitalocean_firewall" "http" {
    name = "http"
    droplet_ids = [
        "${digitalocean_droplet.phishing.id}",
        "${digitalocean_droplet.phishing_rdr.id}"        
        ]
    
    inbound_rule {
            protocol = "tcp"
            port_range = "80"
            source_addresses = ["0.0.0.0/0"]
        }
    inbound_rule {
            protocol = "tcp"
            port_range = "443"
            source_addresses = ["0.0.0.0/0"]
    }

    
    outbound_rule {
            protocol = "tcp"
            port_range = "80"
            destination_addresses = ["0.0.0.0/0"]
    }

    outbound_rule {
            protocol = "tcp"
            port_range = "443"
            destination_addresses = ["0.0.0.0/0"]
    }
}


resource "digitalocean_firewall" "phishing" {
    name = "phishing"
    droplet_ids = ["${digitalocean_droplet.phishing.id}"]

    inbound_rule {
            protocol = "tcp"
            port_range = "3333"
            source_addresses = ["${var.operator_ip}"]
    }

    outbound_rule {
            protocol = "tcp"
            port_range = "25"
            destination_addresses = ["${digitalocean_droplet.phishing_rdr.ipv4_address}"]
    }
}

resource "digitalocean_firewall" "stmp_relay" {
    name = "stmp-relay"
    droplet_ids = ["${digitalocean_droplet.phishing_rdr.id}"]

    inbound_rule {
            protocol = "tcp"
            port_range = "25"
            source_addresses = ["${digitalocean_droplet.phishing.ipv4_address}"]
    }

    outbound_rule {
            protocol = "tcp"
            port_range = "25"
            destination_addresses = ["0.0.0.0/0"]
    }
}