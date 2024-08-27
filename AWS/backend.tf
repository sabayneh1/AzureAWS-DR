terraform {
  backend "s3" {
    bucket         = "my-terraform-awsazure-state-bucket"
    key            = "aws/terraform.tfstate"
    region         = "ca-central-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
