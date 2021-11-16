provider "aws" {
  region = var.region-east
}

provider "aws" {
  alias  = "west"
  region = var.region-west
}