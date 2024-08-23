output "lambda_function_arn" {
  value = aws_lambda_function.trigger_disaster_recovery.arn
}

output "lambda_function_function_name" {
  value = aws_lambda_function.trigger_disaster_recovery.function_name
}
