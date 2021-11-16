data "aws_kms_key" "east-default-key" {
  key_id = "alias/aws/s3"
}

resource "aws_s3_bucket" "S3-bucket-east" {
  bucket = var.S3-bucket-east
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = var.S3-bucket-east
    Environment = var.environment
  }
}

# S3-bucket-west needs replication turned manually post create
resource "aws_s3_bucket" "S3-bucket-west" {
  provider = aws.west
  bucket   = var.S3-bucket-west
  acl      = "private"

  versioning {
    enabled = true
  }

  replication_configuration {
    role = aws_iam_role.S3-rep-role.arn

    rules {
      id     = var.S3-bucket-replication-west-east
      status = "Enabled"

      destination {
        bucket = aws_s3_bucket.S3-bucket-east.arn
      }
    }
  }

  tags = {
    Name        = var.S3-bucket-west
    Environment = var.environment
  }
}


resource "aws_s3_bucket" "S3-bucket-east-logs" {
  bucket        = var.S3-bucket-east-logs
  force_destroy = true

  tags = {
    Name        = var.S3-bucket-east
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "S3-bucket-policy-east-logs" {
  bucket = aws_s3_bucket.S3-bucket-east-logs.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AWSCloudTrailAclCheck",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "${aws_s3_bucket.S3-bucket-east-logs.arn}"
      },
      {
        "Sid" : "AWSCloudTrailWrite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.S3-bucket-east-logs.arn}/replication/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })
  depends_on = [
    aws_s3_bucket.S3-bucket-east-logs
  ]
}

resource "aws_s3_bucket" "S3-bucket-west-logs" {
  bucket        = var.S3-bucket-west-logs
  provider      = aws.west
  force_destroy = true

  tags = {
    Name        = var.S3-bucket-west
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "S3-bucket-policy-west-logs" {
  bucket   = aws_s3_bucket.S3-bucket-west-logs.id
  provider = aws.west
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AWSCloudTrailAclCheck",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "${aws_s3_bucket.S3-bucket-west-logs.arn}"
      },
      {
        "Sid" : "AWSCloudTrailWrite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.S3-bucket-west-logs.arn}/replication/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.S3-bucket-west-logs
  ]
}