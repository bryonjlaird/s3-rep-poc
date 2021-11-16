resource "aws_iam_policy" "S3-rep-policy" {
  name        = var.S3-rep-policy
  path        = "/"
  description = "policy for bi-direction replication"

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "s3:Get*",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${aws_s3_bucket.S3-bucket-east.arn}",
          "${aws_s3_bucket.S3-bucket-east.arn}/*",
          "${aws_s3_bucket.S3-bucket-west.arn}",
          "${aws_s3_bucket.S3-bucket-west.arn}/*",
        ]
      },
      {
        "Action" : [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "S3:GetObjectVersionTagging"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${aws_s3_bucket.S3-bucket-east.arn}/*",
          "${aws_s3_bucket.S3-bucket-west.arn}/*"
        ]
      }
    ],
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_role" "S3-rep-role" {
  name = var.S3-rep-role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.S3-rep-role.name
  policy_arn = aws_iam_policy.S3-rep-policy.arn
}

resource "aws_iam_policy" "S3-cloudtrail-policy" {
  name        = var.S3-cloudtrail-policy
  path        = "/"
  description = "policy for bi-direction replication cloud trail"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AWSCloudTrailCreateLogStream2014110",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream"
        ],
        "Resource" : [
          "${aws_cloudwatch_log_group.S3-bucket-log-group-east.arn}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_us-east-1*",
          "${aws_cloudwatch_log_group.S3-bucket-log-group-west.arn}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_us-west-2*"
        ]
      },
      {
        "Sid" : "AWSCloudTrailPutLogEvents20141101",
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "${aws_cloudwatch_log_group.S3-bucket-log-group-east.arn}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_us-east-1*",
          "${aws_cloudwatch_log_group.S3-bucket-log-group-west.arn}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_us-west-2*"
        ]
      }
    ]
  })
  depends_on = [
    aws_s3_bucket.S3-bucket-east-logs,
    aws_s3_bucket.S3-bucket-west-logs
  ]
}

resource "aws_iam_role" "S3-cloudtrail-role" {
  name = var.S3-cloudtrail-role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "S3-bucket-cloudtrail-attach" {
  role       = aws_iam_role.S3-cloudtrail-role.name
  policy_arn = aws_iam_policy.S3-cloudtrail-policy.arn
}