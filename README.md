# Phishing Infrastructure

A really basic burnable, repeatable phishing infrastructure. This project was heavily inspired from this [ired.team's automated red team infrastructure blog post](https://www.ired.team/offensive-security/red-team-infrastructure/automating-red-team-infrastructure-with-terraform). 

For my current engagements, I didn't need the full phishing/C2/payload infrastructure. Just a basic phishing setup to send, track and report user behaviors. 

## Overview

[GoPhish](https://github.com/gophish/gophish) Is the heart of this set up. 

GoPhish sends (and tracks) the phishing emails and user actions. It also serves the landing page/captures credentials. This GoPhish server can be long term or backup the database and blow away the instance between engagements. 

The virtual servers are hosted with [DigitalOcean](https://www.digitalocean.com). The servers are built and configured using terraform to make the process easily repeatable. 

## DNS Records

A few DNS records are set up automatically. The domains MX record is set to `mail.domain_rdir`. SPF and a DKIM placeholder are configured. The `finalize.sh` script will output the final DKIM string. This will need to be manually added in the DigitalOcean interface.

| Purpose | Variable Name |
| ------- | ------------- |
| mail | this is static, points to the phishing_rdr droplet |
| phishing_subdomain1 | This is how I log into the GoPhish interface |
| phishing_subdomain2 | This is the URL for the landing page when building a GoPhish campaign |

## Firewall Rules

* Only the `operator_ip` can log in over SSH using the configured SSH Keys. 
* The GoPhish server can only send SMTP traffic to the phishing_rdr server
* The servers can reach out to any DNS server
* Any IP can access the HTTP/HTTPS ports. Ideally you should narrow this down if you know the IP range of your target network. 
* Only the `operator_ip` can access the GoPhish admin port (3333)

## High Level Traffic Slow

1. The Operator logs in to GoPhish over HTTPS on port 3333
2. Once the campaign is ready, the GoPhish server will send out the emails to the SMTP relay on the phishing_rdr server
3. The phishing_rdr server will strip sensitive headers from the email and send the emails to the targets
4. Once the user opens and clicks on a link in the phishing email, the user will be sent to `phishing_subdomain2.domain_rdir`. 
5. The phishing_rdr server will relay the target's request using `socat` to the GoPhish server. 
6. The GoPhish server will present the HTTPS SSL certificates and the landing page to the user

## Installation and Initial Use

0. Create your DigitalOcean account and create a domain in the DigitalOcean interface.
1. You need to have [terraform](https://www.terraform.io/downloads.html) installed. 
2. Create a new SSH keypair. You don't want to set a passphrase. Store both the public and private keys in `~/.ssh`
```bash
ssh-keygen -t rsa
```
3. Clone the repo here
4. Copy `variables_sample.tf` to `varaibles.tf`
5. Edit `variables.tf`. Include your DigitalOcean API key, specific domain and desired subdomains. 
6. Run `terraform apply` to see what terraform will do when executed. This is a good chance to catch any errors if there are any. 
7. If everything looks good, run `terraform apply` and type `yes` when prompted. 
8. Wait...it shouldn't be too long...
9. Run the script `finalize.sh`. This will log into these new instances over SSH and set up DKIM and LetsEncrypt SSL certificates.
10. While you wait for the systems to reboot (should have been started in the finalize.sh script, otherwise manually reboot them) - enter the DKIM string output by the finalize.sh script into the DKIM TXT record in the DigitalOcean interface.
11. Now you should be able to SSH into you 2 new systems with the following commands. 
```bash
ssh -i ~/.ssh/id_rsa root@<phishing_subdomain1.domain_rdir>
ssh -i ~/.ssh/id_rsa root@mail.<domain_rdir>
```
**NOTE**: SSH is only accessible from the IP address configured in the `operator_ip` variable using the SSH keys you generated above.


12. Log into the GoPhish server (phishing_subdomain1.domain_rdir). Navigate to `/opt/gophish/` and view the `gophish.log` file. This will have the username and password required to log into the gophish interface. 
13. Log into the GoPhish interface at https://phishing_subdomain1.domain_rdir:3333. This port is only accessible from the IP address configured in the `operator_ip` variable. You will be required to change the password when you first log in. 
14. Phish and raise user awareness.


## Backing Up GoPhish database

The data from gophish is stored in `/opt/gophish/gophish.db`. This file can be downloaded and restored when rebuilding a new GoPhish instance. 

## Future Improvements

* Incorporate an additional HTTP/Phishing/Payload server. This could run [evilginx2](https://github.com/kgretzky/evilginx2) to handle modern two factor logins.
* Add a C2 setup to enable phishing with beacon/implant payloads. This would require a redirector as well to prevent the target system from identifying the long term C2 server. 