variable "aws_region" {
  description = "AWS region to deploy the infrastructure"
  type        = string
  default     = "ap-northeast-1"
}

variable "project" {
  description = "project id"
  type        = string
  default     = "spa-oidc"
}

variable "log_level" {
  type    = string
  default = "DEBUG"

}

variable "env" {
  description = "dev/prod"
  type        = string
  default     = "dev"
}

variable "profile" {
  type     = string
  nullable = false
}

variable "powertools_layer_arn" {
  type    = string
  default = "arn:aws:lambda:ap-northeast-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:73"
}

variable "oidc_url" {
  type     = string
  nullable = false
}

variable "oidc_client_id" {
  type     = string
  nullable = false
}

variable "oidc_client_secret" {
  type     = string
  nullable = false
}


