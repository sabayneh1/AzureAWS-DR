# Monitor 5xx errors on the ALB
resource "aws_cloudwatch_metric_alarm" "alb_5xx_alarm" {
  alarm_name          = "ALB-5XX-Alarm"
  alarm_description   = "Alarm when ALB has more than 5xx errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    LoadBalancer = var.alb_name
  }
}

# Monitor the number of unhealthy hosts behind the ALB
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_host_count_alarm" {
  alarm_name          = "ALB-Unhealthy-Host-Count-Alarm"
  alarm_description   = "Alarm when there are unhealthy hosts behind the ALB"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    LoadBalancer = var.alb_name
  }
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarm_topic" {
  name = "alb-health-alarm-topic"
}

# SNS Topic subscription (this will trigger a Lambda function, for example)
resource "aws_sns_topic_subscription" "alarm_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}

# Grant SNS permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_topic.arn
}
