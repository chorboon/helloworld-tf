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
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# resource "aws_ssm_activation" "web" {
#   name               = "test_ssm_activation"
#   description        = "Test"
#   iam_role           = aws_iam_role.ssm-role.id
#   registration_limit = "5"
#   depends_on         = [aws_iam_role_policy_attachment.dev-resources-ssm-policy]
# }

# resource "aws_ssm_association" "example" {
#   name = "AmazonCloudWatch-ManageAgent"

#   targets {
#     key    = "InstanceIds"
#     values = ["*"]
#   }
# }