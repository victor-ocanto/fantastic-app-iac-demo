terraform {
  backend "s3" {
    bucket         = "terraform-state-884694268658-us-east-1"
    key            = "terraform.tfstate.d/terraform.tfstate"
    region         = "us-east-1"                
    dynamodb_table = "terraform-locks-884694268658" 
    encrypt        = true
  }
}