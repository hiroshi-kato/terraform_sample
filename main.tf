module "web_server" {
  source        = "./http_server"
  instance_type = "t3.micro"
}

# プロバイダ
# aws,gcp,azureなどの設定を定義する
provider "aws" {
  region  = "ap-northeast-1"
  profile = "terraform_sample"
}

# 変数
variable "example_instance_type" {
  default = "t3.micro"
}

# ローカル変数
# variableと違い、コマンド実行時に書き換えができない
locals {
  example_instance_type = "t3.nano"
}

# データソース
# ami等を参照できる
data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "example_ec2" {
  name = "example-ec2"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}
resource "aws_instance" "example" {
  ami                    = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type          = local.example_instance_type
  vpc_security_group_ids = [aws_security_group.example_ec2.id]

  # 組み込み関数
  # 参考：https://www.terraform.io/docs/language/functions/file.html
  user_data = file("./user_data.sh")

  tags = {
    "Name" = "example"
  }
}

# 出力値
output "example_instance_id" {
  value = module.web_server.public_dns
}
