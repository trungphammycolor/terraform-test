terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

variable "aws" {
  default = {
    email_role_ext_id = "cognito-test-email-role-external-id"
  }
}

# IAM role for cognito email
resource "aws_iam_role" "cognito_test_email" {
  name        = "CognitoTest_Email"
  description = "role for applicant cognito, send email"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Condition = {
            StringEquals = {
              "sts:ExternalId" = "${var.aws.email_role_ext_id}"
            }
          }
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "cognito-idp.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/service-role/"
}

resource "aws_iam_role_policy" "cognito_test_email_policy" {
  name = "CognitoTest_Email_Policy"
  role = aws_iam_role.cognito_test_email.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "sns:Publish"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# SES Email Identity for Email Verification
resource "aws_ses_email_identity" "email_identity" {
  email = "trung.pham@mycolor.biz"
}

# SES Identity Policy (Optional: Grants Cognito permissions to use SES)
resource "aws_ses_identity_policy" "email_policy" {
  name     = "SES_Identity_Policy"
  identity = aws_ses_email_identity.email_identity.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cognito-idp.amazonaws.com"
        },
        "Action" : "ses:SendEmail",
        "Resource" : aws_ses_email_identity.email_identity.arn
      }
    ]
  })
}


# Create the Admin User Pool
resource "aws_cognito_user_pool" "cognito_test_user_pool" {
  name                     = "cognito-test-user-pool"
  auto_verified_attributes = ["email"]
  mfa_configuration        = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }
  email_configuration {
    email_sending_account  = "DEVELOPER"
    source_arn             = aws_ses_email_identity.email_identity.arn
    reply_to_email_address = "trung.pham@mycolor.biz"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_message = "Your username is {username}, and your temporary password is {####}."
      email_subject = "Temporary Password"
      sms_message   = "Your username is {username}, and your temporary password is {####}."
    }
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

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "The verification code is {####}."
    email_subject        = "Verification code"
  }
}

# Create User Groups
resource "aws_cognito_user_group" "admin_group" {
  user_pool_id = aws_cognito_user_pool.cognito_test_user_pool.id
  name         = "Admins"
  description  = "Group for admin users"
}

# Create Admin Users for Testing
resource "aws_cognito_user" "admin_user" {
  user_pool_id = aws_cognito_user_pool.cognito_test_user_pool.id
  username     = "admin_user"
  attributes = {
    email = "admin@example.com"
  }
  temporary_password   = "TempPassword123!"
  force_alias_creation = false
  message_action       = "SUPPRESS"
}

# Add Admin User to Admin Group
resource "aws_cognito_user_in_group" "admin_user_membership" {
  user_pool_id = aws_cognito_user_pool.cognito_test_user_pool.id
  username     = aws_cognito_user.admin_user.username
  group_name   = aws_cognito_user_group.admin_group.name
}

# User Pool Client
resource "aws_cognito_user_pool_client" "cognito_test_client" {
  name                                 = "cognito-test-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.cognito_test_user_pool.id
  access_token_validity                = 5
  allowed_oauth_flows_user_pool_client = false
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]
  id_token_validity             = 5
  prevent_user_existence_errors = "ENABLED"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
  ]
  refresh_token_validity = 30 # Changed to 30 hours
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "hours" # Changed to hours
  }
}

# Identity Pool
resource "aws_cognito_identity_pool" "cognito_test_identity_pool" {
  identity_pool_name = "cognito-test-id-pool"
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognito_test_client.id
    provider_name           = "cognito-idp.ap-northeast-1.amazonaws.com/${aws_cognito_user_pool.cognito_test_user_pool.id}"
    server_side_token_check = false
  }
}

# IAM role for Identity Authenticated
resource "aws_iam_role" "cognito_test_identity_authenticated" {
  name = "CognitoTestIdentityPool_Authenticated_Role"
  path = "/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = "cognito-identity.amazonaws.com"
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            "ForAnyValue:StringLike" = {
              "cognito-identity.amazonaws.com:amr" = "authenticated"
            }
            "StringEquals" = {
              "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.cognito_test_identity_pool.id
            }
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
}

resource "aws_iam_role_policy" "cognito_test_identity_authenticated_policy" {
  name = "oneClick_CognitoTestIdentityPool_Authenticated_Role"
  role = aws_iam_role.cognito_test_identity_authenticated.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "mobileanalytics:PutEvents",
            "cognito-sync:*",
            "cognito-identity:*",
          ]
          Effect = "Allow"
          Resource = [
            "*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# IAM role for Identity Unauthenticated
resource "aws_iam_role" "cognito_test_identity_unauthenticated" {
  name                  = "CognitoTestIdentityPool_Unauthenticated_Role"
  path                  = "/"
  assume_role_policy    = jsonencode(
    {
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Federated = "cognito-identity.amazonaws.com"
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            "StringEquals" = {
              "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.cognito_test_identity_pool.id
            }
            "ForAnyValue:StringLike" = {
              "cognito-identity.amazonaws.com:amr" = "unauthenticated"
            }
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
}

resource "aws_iam_role_policy" "cognito_test_identity_unauthenticated_policy" {
  name = "oneClick_CognitoTestIdentityPool_Unauthenticated_Role"
  role = aws_iam_role.cognito_test_identity_unauthenticated.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "mobileanalytics:PutEvents",
            "cognito-sync:*",
          ]
          Effect = "Allow"
          Resource = [
            "*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# Auth Role attachment (OK and NG)
resource "aws_cognito_identity_pool_roles_attachment" "cognito_test_identity_pool_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.cognito_test_identity_pool.id
  roles = {
    "authenticated"   = aws_iam_role.cognito_test_identity_authenticated.arn
    "unauthenticated" = aws_iam_role.cognito_test_identity_unauthenticated.arn
  }
}
