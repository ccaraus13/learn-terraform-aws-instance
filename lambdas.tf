resource "aws_lambda_function" "create_db_api_user_lambda" {
  architectures = ["arm64"]
  package_type = "Image"
  image_uri = var.lambda_create_api_user_ecr_uri

  role          = var.lambda_create_api_user
  function_name = "create_db_api_user"
  timeout = 6

  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids         = aws_subnet.private_subnets[*].id
  }

  environment {
    variables = {
      PARAMETERS_SECRETS_EXTENSION_LOG_LEVEL = "INFO"
    }
  }

}
