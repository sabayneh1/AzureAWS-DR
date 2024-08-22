resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "trigger_disaster_recovery" {
  function_name = "trigger_disaster_recovery"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "function.zip" # Replace with your actual deployment package

  environment {
    variables = {
      GITHUB_REPO = "https://github.com/sabayneh1/AzureAWS-DR.git"
      # Add any other necessary environment variables here
    }
  }
}


resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:DescribeInstances",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "sns:Publish",
          "cloudwatch:PutMetricData",
          "elasticloadbalancing:Describe*",
          "ec2:DescribeTags",
          "ec2:DescribeRegions"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
