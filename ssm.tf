data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "ec2_profile"
  role = aws_iam_role.ssm-role.name
}

resource "aws_iam_role" "ssm-role" {
  name               = "ssm-role"
  description        = "The role for ssm resources EC2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.ssm-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# resource "aws_directory_service_directory" "ad" {
#   name     = "active-directory-service.com"
#   password = "${var.ad-password}"
#   edition  = "Standard"
#   size     = "Small"
#   type     = "MicrosoftAD"

#   vpc_settings {
#     vpc_id     = "${aws_vpc.vpc.id}"
#     subnet_ids = ["${aws_subnet.ds-subnet.0.id}", 
#                   "${aws_subnet.ds-subnet.1.id}"
#                   ]
#   }

# }
# resource "aws_vpc_dhcp_options" "vpc-dhcp-options" {
#   domain_name          = "${var.dir_domain_name}"
#   domain_name_servers  = aws_directory_service_directory.ad.dns_ip_addresses

# }
# resource "aws_vpc_dhcp_options_association" "dns_resolver" {
#    vpc_id          =  aws_vpc.vpc.id
#    dhcp_options_id = aws_vpc_dhcp_options.vpc-dhcp-options.id
# }
#resource "aws_ssm_document" "ad-server-domain-join-document" {
#    name  = "myapp_dir_default_doc"
#    document_type = "Command"

#content = <<DOC
#{
#         "schemaVersion": "1.0",
#         "description": "Join an instance to a domain",
#         "runtimeConfig": {
#            "aws:domainJoin": {
#                "properties": {
#                   "directoryId": "${aws_directory_service_directory.ad.id}",
#                   "directoryName": "${var.dir_domain_name}",
#                   "directoryOU": "${var.dir_computer_ou}",
#                   "dnsIpAddresses": [
#                      "${aws_directory_service_directory.ad.dns_ip_addresses[0]}",
#                      "${aws_directory_service_directory.ad.dns_ip_addresses[1]}"
#                }
#            }
#         }
# }
# DOC
# }
# resource "aws_ssm_association" "ad-server-association" {
#     name = "dir_default_doc"
#     instance_id = aws_instance.ec2-ad-instance.id
# }