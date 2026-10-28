terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "k8s-lab-tfstate-560617058687"
    key          = "k8s-lab/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}
