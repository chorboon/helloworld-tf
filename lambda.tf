provider "archive" {}

resource "aws_iam_role" "iam_for_lambda" {
   name               = "iam_for_lambda"
   assume_role_policy = data.aws_iam_policy_document.assume_role.json
 }

data "archive_file" "lambda" {
   type        = "zip"
   source_file = "lambda.py"
   output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  
  filename      = "lambda.zip"
  function_name = "lambda_function_name"
  architectures = "arm64"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

#environment {
#     variables = {
#       foo = "bar"
#     }
#   }
 }