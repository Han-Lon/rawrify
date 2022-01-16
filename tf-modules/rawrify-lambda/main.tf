resource "aws_iam_role" "rawrify-lambda-role" {
  name = "rawrify-${var.environment}-${var.function_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "rawrify-lambda-role-attach-basic-execution" {
  count = var.enable_basic_execution_role ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.rawrify-lambda-role.id
}

data "archive_file" "rawrify-lambda-code-zip" {
  output_path = var.output_path
  type = "zip"
  source_file = var.input_path
}

resource "aws_lambda_function" "rawrify-lambda" {
  function_name = "rawrify-${var.function_name}-${var.environment}"
  handler = "main.lambda_handler"
  role = aws_iam_role.rawrify-lambda-role.arn
  runtime = "python3.8"
  architectures = [var.architecture]

  layers = var.lambda_layer_arns == [""] ? null : var.lambda_layer_arns

  filename = data.archive_file.rawrify-lambda-code-zip.output_path
  source_code_hash = data.archive_file.rawrify-lambda-code-zip.output_base64sha256

  environment {
    variables = {
      ENV = var.environment
    }
  }

  tags = {
    Name = "${var.function_name}-${var.environment}"
  }
}

resource "aws_lambda_permission" "rawrify-lambda-permission" {
  statement_id = "AllowAPIGateway-${aws_lambda_function.rawrify-lambda.function_name}"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rawrify-lambda.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${var.api_execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "rawrify-lambda-log-group" {
  name              = "/aws/lambda/${aws_lambda_function.rawrify-lambda.function_name}"
  retention_in_days = 7

  tags = {
    Name = "${aws_lambda_function.rawrify-lambda.function_name}-log-group"
  }
}