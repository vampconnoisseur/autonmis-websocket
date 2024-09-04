# CloudWatch metric alarm for request count
resource "aws_cloudwatch_metric_alarm" "ecs_inactivity_alarm" {
  alarm_name          = "ecs-inactivity-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    LoadBalancer = var.alb_suffix
  }

  alarm_actions = [aws_sns_topic.ecs_alarm_topic.arn]
}

# SNS Topic to trigger Lambda
resource "aws_sns_topic" "ecs_alarm_topic" {
  name = "ecs-alarm-topic"
}

resource "aws_sns_topic_subscription" "ecs_alarm_subscription" {
  topic_arn = aws_sns_topic.ecs_alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.delete_ecs_service.arn
}

# resource "aws_lambda_function" "delete_ecs_service" {
#   function_name = "delete-ecs-service"
#   handler       = "lambda_delete_service.lambda_handler"
#   runtime       = "python3.9"
#   role          = aws_iam_role.lambda_exec_role.arn
#   timeout       = 300

#   # The ZIP file containing your Lambda code
#   filename         = "lambda_delete_service.py.zip"
#   source_code_hash = filebase64sha256("lambda_delete_service.py.zip")

#   environment {
#     variables = {
#       REGION   = var.region
#       USERNAME = var.username
#     }
#   }
# }

resource "aws_lambda_function" "delete_ecs_service" {
  function_name = "delete-ecs-service"
  handler       = "index.handler"  # Node.js entry point
  runtime       = "nodejs18.x"      # Use Node.js 18.x runtime
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 300

  # The ZIP file containing your Lambda code
  filename         = "lambda_delete_service.zip"
  source_code_hash = filebase64sha256("lambda_delete_service.zip")

  environment {
    variables = {
      REGION   = var.region
      USERNAME = var.username
    }
  }
}

# IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

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

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name   = "lambda_exec_policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:UpdateService",
          "ecs:DeleteService",
          "ecs:DescribeServices",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_sns_invoke_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_ecs_service.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ecs_alarm_topic.arn
}