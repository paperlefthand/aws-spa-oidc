resource "aws_cognito_user_pool" "pool" {
  alias_attributes           = null
  auto_verified_attributes   = ["email"]
  deletion_protection        = "ACTIVE"
  email_verification_message = null
  email_verification_subject = null
  mfa_configuration          = "OFF"
  name                       = var.project
  sms_authentication_message = null
  sms_verification_message   = null
  tags                       = {}
  tags_all                   = {}
  username_attributes        = ["email"]
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  email_configuration {
    configuration_set      = null
    email_sending_account  = "COGNITO_DEFAULT"
    from_email_address     = null
    reply_to_email_address = null
    source_arn             = null
  }
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }
  username_configuration {
    case_sensitive = false
  }
  verification_message_template {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_message         = null
    email_message_by_link = null
    email_subject         = null
    email_subject_by_link = null
    sms_message           = null
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project}-dev"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  access_token_validity                         = 60
  allowed_oauth_flows                           = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client          = true
  allowed_oauth_scopes                          = ["phone", "email", "openid", "profile"]
  auth_session_validity                         = 3
  callback_urls                                 = [var.signin_url]
  default_redirect_uri                          = null
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = true
  explicit_auth_flows                           = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  generate_secret                               = null
  id_token_validity                             = 60
  logout_urls                                   = [var.signout_url]
  name                                          = var.project
  prevent_user_existence_errors                 = "ENABLED"
  read_attributes                               = ["address", "birthdate", "email", "email_verified", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
  refresh_token_validity                        = 30
  supported_identity_providers                  = [aws_cognito_identity_provider.idp.provider_name]
  user_pool_id                                  = aws_cognito_user_pool.pool.id
  write_attributes                              = ["address", "birthdate", "email", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_identity_provider" "idp" {
  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
  idp_identifiers = []
  provider_details = {
    attributes_request_method     = "GET"
    attributes_url                = "${var.oidc_url}/userinfo"
    attributes_url_add_attributes = "false"
    authorize_scopes              = "email openid name nickname"
    authorize_url                 = "${var.oidc_url}/authorize"
    client_id                     = var.oidc_client_id
    client_secret                 = var.oidc_client_secret
    jwks_uri                      = "${var.oidc_url}/.well-known/jwks.json"
    oidc_issuer                   = "${var.oidc_url}"
    token_url                     = "${var.oidc_url}/oauth/token"
  }
  provider_name = "auth0"
  provider_type = "OIDC"
  user_pool_id  = aws_cognito_user_pool.pool.id
}


resource "aws_cognito_identity_pool" "idpool" {
  allow_classic_flow               = false
  allow_unauthenticated_identities = false
  developer_provider_name          = null
  identity_pool_name               = var.project
  openid_connect_provider_arns     = []
  saml_provider_arns               = []
  supported_login_providers        = {}
  tags                             = {}
  tags_all                         = {}
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = "cognito-idp.ap-northeast-1.amazonaws.com/${aws_cognito_user_pool.pool.id}"
    server_side_token_check = false
  }
}
