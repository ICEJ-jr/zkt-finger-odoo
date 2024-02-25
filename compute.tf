data "aws_ami" "server_ami" {
  most_recent = true

  owners = var.ami_owners

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "odoo_16_node" {
  byte_length = 2
  count       = var.main_instance_count
}

resource "aws_key_pair" "odoo_16_node_id" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "odoo_16_server" {
  count = var.main_instance_count
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.odoo_16_node_id.id
  vpc_security_group_ids = [aws_security_group.odoo_16_sg.id]
  subnet_id = aws_subnet.odoo_16_public_subnet[count.index].id # aws_subnet.odoo_16_public_subnet[count.index].id
  user_data = file("./install_docker.sh")
  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name = "odoo-16-server-${random_id.odoo_16_node[count.index].dec}"
  }
}
