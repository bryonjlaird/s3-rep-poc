data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "S3-bucket-log-group-east" {
  name = var.S3-bucket-log-group-east
}

resource "aws_cloudtrail" "S3-bucket-trail-east" {
  name                          = var.S3-bucket-trail-east
  s3_bucket_name                = aws_s3_bucket.S3-bucket-east-logs.id
  s3_key_prefix                 = "replication"
  include_global_service_events = false

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"

      # Make sure to append a trailing '/' to your ARN if you want
      # to monitor all objects in a bucket.
      values = ["${aws_s3_bucket.S3-bucket-east.arn}/"]
    }
  }
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.S3-bucket-log-group-east.arn}:*"

  cloud_watch_logs_role_arn = aws_iam_role.S3-cloudtrail-role.arn

  depends_on = [
    aws_s3_bucket.S3-bucket-east-logs,
    aws_iam_role.S3-cloudtrail-role,
    aws_iam_policy.S3-cloudtrail-policy,
    aws_cloudwatch_log_group.S3-bucket-log-group-east    
  ]
}

resource "aws_cloudwatch_log_group" "S3-bucket-log-group-west" {
  provider = aws.west
  name     = var.S3-bucket-log-group-west
}

resource "aws_cloudtrail" "S3-bucket-trail-west" {
  name                          = var.S3-bucket-trail-west
  s3_bucket_name                = aws_s3_bucket.S3-bucket-west-logs.id
  s3_key_prefix                 = "replication"
  include_global_service_events = false
  provider                      = aws.west

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"

      # Make sure to append a trailing '/' to your ARN if you want
      # to monitor all objects in a bucket.
      values = ["${aws_s3_bucket.S3-bucket-west.arn}/"]
    }
  }
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.S3-bucket-log-group-west.arn}:*"

  cloud_watch_logs_role_arn = aws_iam_role.S3-cloudtrail-role.arn

  depends_on = [
    aws_s3_bucket.S3-bucket-west-logs,
    aws_iam_role.S3-cloudtrail-role,
    aws_iam_policy.S3-cloudtrail-policy,
    aws_cloudwatch_log_group.S3-bucket-log-group-west
  ]
}