# DIGITAL OCEAN VARIABLES
variable "do_token" {
    default = ""
}
variable "region" { default="" }
variable pvt_key { default="~/.ssh/id_rsa" }

# LOGINS
variable "operator_ip" {
    default = ""
}

# CAMPAIGN VARIABLES

variable "gophish_zip_url" {
    default = "https://github.com/gophish/gophish/releases/download/v0.11.0/gophish-v0.11.0-linux-64bit.zip"
}

## DOMAINS and SUBDOMAINS
variable "domain_rdir" {
    default = "example.com"
}

variable "phishing_subdomain1" {
    default = "phish"
}

variable "phishing_subdomain2" {
    default = "www"
}