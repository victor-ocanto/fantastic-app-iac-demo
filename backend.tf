terraform {
  backend "s3" {
    bucket         = "Replace with your S3 bucket name"  
    key            = "terraform.tfstate.d/terraform.tfstate"
    region         = "us-east-1"                # Replace with your AWS region
    dynamodb_table = "Replace with your DynamoDB table for state locking"
    encrypt        = true
  }
}