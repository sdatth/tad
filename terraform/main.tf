resource "digitalocean_droplet" "web2" {
  image  = "ubuntu-20-04-x64"
  name   = "web2"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.pvt_key)
    }
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ../ansible/
      ansible-playbook -u root -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' --vault-password-file vaultkey add_user.yml
      ansible-playbook -u ${var.username} -i '${self.ipv4_address},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' -e "username=${var.username}" -e ansible_become_pass=${var.upass} site.yml
    EOT
  }
}

