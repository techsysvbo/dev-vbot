data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

}
resource "random_id" "dev_node_id" {
  byte_length = 2
  count       = var.main_instance_count
}

# Key Pair
resource "aws_key_pair" "dev_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "dev_main" {
  count                  = var.main_instance_count
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.dev_key.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  # subnet_id              = aws_subnet.public_subnet[0].id
  subnet_id = aws_subnet.public_subnet[count.index].id
  #user_data = templatefile("./main-userdata.tpl", { new_hostname = "dev-main-${random_id.dev_node_id[count.index].dec}" }) # COMMent out if using Ansible
  root_block_device {
    volume_size = var.main_vol_size
  }
  tags = {
    # Name = "dev-main"
    Name = "dev-main-${random_id.dev_node_id[count.index].dec}"
  }

  // Comment out both provisioners below once u reach lesson 92: Using custom Outputs
  # provisioner "local-exec" {
  #   command = "printf '\n${self.public_ip}' >> aws_hosts && aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-east-1"
  # }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = "sed -i '/^[0-9]/d' aws_hosts"
  # }
} // dont comment out this brace

# resource "null_resource" "grafana_install" {
#   depends_on = [aws_instance.dev_main]
#   provisioner "local-exec" {
#     #command = "ansible-playbook -i aws_hosts --key-file  /mnt/c/Users/victo/.ssh/devkey playbooks/grafana.yml"
#     command = "echo 'Hello'" #"ansible-playbook -i aws_hosts --key-file /mnt/c/Users/victo/.ssh/devkey playbook/grafana.yml"
#   }

# }

# output "grafana_access" {
#   value = {}
# }

# ## Ansible Integration
# resource "null_resource" "grafana_update" {
#   depends_on = [aws_instance.dev_main]
#   provisioner "local-exec" {
#     command = "echo 'Hello'" #"ansible-playbook -i aws_hosts --key-file /mnt/c/Users/victo/.ssh/devkey playbook/grafana.yml" # Make sure userdata is commented out as well as remote exec
#   }
# }


### Ansible Integration Ends 

## Remote Exec. Not advisable for Production workloads. 
# resource "null_resource" "grafana_update" {
#   count = var.main_instance_count
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt upgrade -y grafana",
#       "touch upgrade.log",
#       "echo 'I Updated Grafana' >> upgrade.log"
#     ]
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file("c:/Users/victo/.ssh/devkey")
#       host        = aws_instance.dev_main[count.index].public_ip
#     }
#   }
# }