resource "aws_subnet" "ad-subnet-1" {
  vpc_id            = aws_vpc.HelloWorld_vpc_1.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "us-east-1a"
  #  map_public_ip_on_launch = true

}
resource "aws_subnet" "ad-subnet-2" {
  vpc_id            = aws_vpc.HelloWorld_vpc_1.id
  cidr_block        = "10.0.31.0/24"
  availability_zone = "us-east-1b"
  #  map_public_ip_on_launch = true

}

resource "aws_directory_service_directory" "ad" {
  name     = "active-directory-service.com"
  password = var.ad-password
  edition  = "Standard"
  size     = "Small"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.HelloWorld_vpc_1.id
    subnet_ids = ["${aws_subnet.ad-subnet-1.id}","${aws_subnet.ad-subnet-2.id}"]
  }
}
resource "aws_vpc_dhcp_options" "vpc-dhcp-options" {
  domain_name         = "ad_domain_name"
  domain_name_servers = aws_directory_service_directory.ad.dns_ip_addresses

}
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.HelloWorld_vpc_1.id
  dhcp_options_id = aws_vpc_dhcp_options.vpc-dhcp-options.id
}

resource "aws_ssm_document" "ad-server-domain-join-document" {
  name          = "myapp_dir_default_doc"
  document_type = "Command"

  content = <<DOC
{
        "schemaVersion": "1.0",
        "description": "Join an instance to a domain",
        "runtimeConfig": {
           "aws:domainJoin": {
               "properties": {
                  "directoryId": "${aws_directory_service_directory.ad.id}",
                  "directoryName": "${var.dir_domain_name}",
                  "directoryOU": "${var.dir_computer_ou}",
                  "dnsIpAddresses": ["${tolist(aws_directory_service_directory.ad.dns_ip_addresses)[0]}"]
               }
           }
        }
}
DOC
}
resource "aws_ssm_association" "ad-server-association" {
  name        = "myapp_dir_default_doc"
  instance_id = aws_instance.database.id
}