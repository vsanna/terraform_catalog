terraform {
  backend "s3" {
    bucket = "dd-tfstate"
    key = "examples/securitygroup"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "ssm_params" {
  source = "../../modules/ssm"
  name = "sample_val"
}



/*
# NOTE:
This module just creats placeholder for the given name.
After applying this terraform script, run a command below
aws ssm put-parameter --name {name} --type SecureString --value {actual_value} --overwrite

# NOTE:
probably you should use SecretManager instead of SystemManager's ParameterStore.
*/