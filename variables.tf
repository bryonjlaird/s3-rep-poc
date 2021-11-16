variable "region-east" {
  type = string
}

variable "region-west" {
  type = string
}

variable "environment" {
  type = string
}

variable "S3-bucket-east" {
  type = string
}

variable "S3-bucket-west" {
  type = string
}

variable "S3-bucket-east-logs" {
  type = string
}

variable "S3-bucket-west-logs" {
  type = string
}

variable "S3-rep-policy" {
  type = string
}

variable "S3-rep-role" {
  type = string
}

variable "S3-cloudtrail-policy" {
  type = string
}

variable "S3-cloudtrail-role" {
  type = string
}

variable "S3-bucket-log-group-east" {
  type = string
}

variable "S3-bucket-log-group-west" {
  type = string
}

variable "S3-bucket-trail-east" {
  type = string
}
variable "S3-bucket-trail-west" {
  type = string
}

variable "S3-bucket-replication-east-west" {
  type = string
}

variable "S3-bucket-replication-west-east" {
  type = string
}
