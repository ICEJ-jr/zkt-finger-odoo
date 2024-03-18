data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "random_id" "zkt_node" {
  byte_length = 2
  count       = var.main_instance_count
}

resource "aws_key_pair" "zkt_node_id" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "zkt_server" {
  count = var.main_instance_count
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.zkt_node_id.id
  vpc_security_group_ids = [aws_security_group.zkt_sg.id]
  subnet_id = aws_subnet.zkt_server_public_subnet[count.index].id # aws_subnet.zkt_public_subnet[count.index].id
  user_data = file("./install_docker.sh")
  
  root_block_device {
    volume_size = var.main_vol_size
  }

  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip}"
  # }

  tags = {
    Name = "zkt-server-${random_id.zkt_node[count.index].dec}"
  }
}
