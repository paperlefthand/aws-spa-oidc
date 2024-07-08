resource "aws_iam_role" "main" {
  name = var.project
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_basic_exe_policy" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "main" {
  function_name    = var.project
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_function.output_path)
  role             = aws_iam_role.main.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 3
  layers           = [var.powertools_layer_arn]
  environment {
    variables = {
      POWERTOOLS_LOG_LEVEL    = var.log_level,
      POWERTOOLS_SERVICE_NAME = var.project
    }
  }
}