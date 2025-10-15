# Configure the Auth0 Provider
terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1.0"
}

# Configure Auth0 Provider
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

# Auth0 Tenant Configuration
resource "auth0_tenant" "tenant" {
  friendly_name      = var.tenant_friendly_name
  support_email      = var.tenant_support_email
  support_url        = var.tenant_support_url
  #default_audience   = var.tenant_default_audience
  #default_directory  = "Username-Password-Authentication"
  #Logo URL
  picture_url        = "https://www.shutterstock.com/shutterstock/photos/2174926871/display_1500/stock-vector-circle-line-simple-design-logo-blue-format-jpg-png-eps-2174926871.jpg"
  
   # Set Idle Session Lifetime (in minutes)
  idle_session_lifetime  = 24  # 1 day

  # Set Maximum Session Lifetime (in minutes)
  session_lifetime       = 480 # 20 days
  
  # Session cookie persistence policy: "persistent" or "non_persistent"
  # session_cookie is not a supported argument, removed
}

#Authentication Profile Configuration
resource "auth0_prompt" "tenant_prompt" {
  universal_login_experience = "new"
  identifier_first           = true
}

# Custom Domain Configuration
#resource "auth0_custom_domain" "domain" {
#  count  = var.custom_domain_name != "" ? 1 : 0
#  domain = var.custom_domain_name
#  type   = var.custom_domain_type
#}

# Attack Protection
resource "auth0_attack_protection" "breached_password_detection" {
  dynamic "breached_password_detection" {
    for_each = var.enable_breach_detection ? [1] : []
    content {
      enabled = true
      method  = var.enable_enhanced_breach_detection ? "enhanced" : "standard" # Use "enhanced" for Credential Guard, otherwise "standard" for regular public breach lists

      shields = [
        "block",
        "admin_notification",
        # "user_notification" # Add only if you want users notified directly
      ]

      admin_notification_frequency = ["immediately"] # Can also be "daily", "weekly", or "monthly"

      # Optionally enable/disable user notifications:
      # user_notification_enabled = false   # Only if provider supports this option

      # Example: disable user notification for compromised credentials
      # You may need to use management API for fine-grained settings if this option is not exposed in the provider
    }
  }
  
  brute_force_protection {
    enabled = true                # Enable brute-force protection
    shields = ["block", "user_notification"]    # Block login attempts, send notification to the user

    # threshold is not specified so it uses Auth0's default (recommended for most cases)
    # If you need to customize: 
    # threshold = <number of allowed attempts before account is blocked>
  }
  
  suspicious_ip_throttling {
    enabled = true
    shields = ["block", "admin_notification"]  # Block and send notifications to admins
    # By not specifying thresholds, Auth0 default thresholds are used.
  }
}


# Branding configuration
resource "auth0_branding" "tenant_branding" {
  logo_url = "https://www.shutterstock.com/shutterstock/photos/2174926871/display_1500/stock-vector-circle-line-simple-design-logo-blue-format-jpg-png-eps-2174926871.jpg"

  colors {
    primary          = "#123456"     # Primary color
    page_background  = "#f4f4f4"     # Page background color
  }
}

# Enable custom email provider
resource "auth0_email_provider" "custom_provider" {
  count     = var.create_email_templates ? 1 : 0
  name      = "smtp"
  default_from_address = "no-reply@yourdomain.com"
  credentials {
  smtp_host   = var.smtp_host
  smtp_port   = var.smtp_port
  smtp_user   = var.smtp_user
  smtp_pass   = var.smtp_pass
  }
}

# Email template example - Reset Password
resource "auth0_email_template" "reset_password" {
  count      = var.create_email_templates ? 1 : 0
  depends_on = [auth0_email_provider.custom_provider]
  template        = "reset_email"  # Email template identifier
  subject         = "Reset your password"
  from            = "no-reply@yourdomain.com"
  body            = "Click the link to reset your password." # Replace with file() if the file exists
  syntax          = "liquid"
  enabled         = true
}

# Resource server for legacy API (will be consolidated with the one below)

#Log Stream Configuration
resource "auth0_log_stream" "splunk_cribl" {
  count  = var.create_log_stream ? 1 : 0
  name   = "Cribl"
  type   = "splunk"
  status = "active"

  sink {
    splunk_domain = "default.main.dreamy-moore-3stzf1x.cribl.cloud"
    splunk_port   = 20001
    splunk_token  = "<Your Cribl/Splunk Event Collector Token>"
    splunk_secure = true
  }

  # Prioritized logs disabled (default)
  # No filter needed for "All"
}


# Add missing role resources
resource "auth0_role" "admin" {
  count       = var.create_admin_role ? 1 : 0
  name        = "Admin"
  description = "Administrator role with full access"
}

resource "auth0_role" "user" {
  count       = var.create_user_role ? 1 : 0
  name        = "User"
  description = "Standard user role"
}

# Auth0 Action (Login Flow) - first instance removed, consolidated below

# Multiple Auth0 Applications
resource "auth0_client" "applications" {
  for_each = var.skip_existing_applications ? {} : var.applications

  name                = each.value.name
  description         = each.value.description
  app_type            = each.value.type == "spa" ? "spa" : "non_interactive"
  callbacks           = each.value.type == "spa" ? each.value.callbacks : null
  allowed_logout_urls = each.value.type == "spa" ? each.value.logout_urls : null
  allowed_origins     = each.value.type == "spa" ? each.value.allowed_origins : null
  web_origins         = each.value.type == "spa" ? each.value.web_origins : null
  oidc_conformant     = true
  
  jwt_configuration {
    lifetime_in_seconds = 36000
    secret_encoded      = true
    alg                 = "RS256"
  }
}

# Resource Servers for API Applications
resource "auth0_resource_server" "apis" {
  for_each = var.skip_existing_resource_servers ? {} : {
    for k, v in var.applications : k => v
    if v.type == "api"
  }

  name        = each.value.name
  identifier  = each.value.api_identifier
  signing_alg = "RS256"

  allow_offline_access = true
  token_lifetime      = 86400
  skip_consent_for_verifiable_first_party_clients = true

  lifecycle {
    ignore_changes = [
      identifier,
      name,
      signing_alg,
      allow_offline_access,
      token_lifetime,
      skip_consent_for_verifiable_first_party_clients
    ]
  }
}

# API Scopes
resource "auth0_resource_server_scopes" "api_scopes_new" {
  for_each = var.skip_existing_resource_servers ? {} : {
    for k, v in var.applications : k => v
    if v.type == "api" && length(v.api_scopes) > 0
  }

  resource_server_identifier = auth0_resource_server.apis[each.key].identifier

  dynamic "scopes" {
    for_each = each.value.api_scopes
    content {
      name        = scopes.value.name
      description = scopes.value.description
    }
  }
}

# Roles
resource "auth0_role" "roles" {
  for_each = var.roles

  name        = each.value.name
  description = each.value.description
}

# Role Permissions
resource "auth0_role_permission" "role_permissions" {
  for_each = {
    for entry in flatten([
      for role_key, role in var.roles : [
        for permission in role.permissions : {
          role_key     = role_key
          resource_server_identifier = permission.resource_server_identifier
          permission_name = permission.name
        }
      ]
    ]) : "${entry.role_key}-${entry.permission_name}" => entry
  }

  role_id = auth0_role.roles[each.value.role_key].id
  resource_server_identifier = each.value.resource_server_identifier
  permission = each.value.permission_name
}

# Legacy Auth0 Application (API/Backend) - maintained for backward compatibility
resource "auth0_client" "api_app" {
  count       = (var.api_app_name != "" && !var.skip_existing_applications) ? 1 : 0
  name        = var.api_app_name
  description = "API Application for ${var.project_name}"
  app_type    = "non_interactive"
  
  jwt_configuration {
    lifetime_in_seconds = 36000
    secret_encoded      = true
    alg                 = "RS256"
  }
}

# Legacy Auth0 Resource Server (API) - maintained for backward compatibility
resource "auth0_resource_server" "api" {
  count = (var.api_name != "" && var.create_resource_server && !var.skip_existing_resource_servers) ? 1 : 0
  
  name       = var.api_name
  identifier = var.api_identifier

  allow_offline_access                            = true
  token_lifetime                                 = 86400
  token_lifetime_for_web                         = 7200
  skip_consent_for_verifiable_first_party_clients = true

  lifecycle {
    ignore_changes = [
      identifier,
      name,
      allow_offline_access,
      token_lifetime,
      token_lifetime_for_web,
      skip_consent_for_verifiable_first_party_clients
    ]
  }
}

# Auth0 Client Grant (API permissions) - DISABLED
# This legacy resource is disabled as it conflicts with the new applications structure
# Client grants are managed through the applications configuration
# resource "auth0_client_grant" "api_grant" {
#   count     = 0  # Disabled
#   client_id = ""
#   audience  = ""
#   
#   scopes = [
#     "read:users",
#     "write:users"
#   ]
# }

# Auth0 Connection (Database)
resource "auth0_connection" "database" {
  count    = var.skip_existing_database ? 0 : 1
  name     = replace(lower("${var.project_name}-db"), " ", "-")
  strategy = "auth0"
  
  options {
    password_policy                = "good"
    password_history {
      enable = true
      size   = 5
    }
    password_no_personal_info {
      enable = true
    }
    password_dictionary {
      enable     = true
      dictionary = ["password", "admin", "123456"]
    }
    password_complexity_options {
      min_length = 8
    }
    enabled_database_customization = true
    brute_force_protection         = true
    import_mode                    = false
    disable_signup                 = false
    requires_username              = false
  }
}

# Enable connection for applications
resource "auth0_connection_clients" "app_connections" {
  count         = var.skip_existing_database ? 0 : 1
  connection_id = auth0_connection.database[0].id
  enabled_clients = [
    for k, v in auth0_client.applications : v.id if v.app_type == "spa"
  ]
}

# Role permissions are now handled by the auth0_role_permission resource with for_each

# Check if we should skip creating actions based on variable
locals {
  skip_action_creation = var.skip_existing_action || !var.create_login_action
}

# Auth0 Action (Login Flow)
resource "auth0_action" "login_action" {
  count = !local.skip_action_creation ? 1 : 0
  name  = "add-user-metadata"
  
  supported_triggers {
    id      = "post-login"
    version = "v3"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      code,
      dependencies,
      runtime
    ]
  }
  
  code = <<-EOT
    exports.onExecutePostLogin = async (event, api) => {
      const namespace = 'https://example.com';
      
      if (event.authorization) {
        api.idToken.setCustomClaim(namespace + '/roles', event.authorization.roles);
        api.accessToken.setCustomClaim(namespace + '/roles', event.authorization.roles);
      }
      
      api.user.setAppMetadata('last_login', new Date().toISOString());
    };
  EOT
  
  dependencies {
    name    = "lodash"
    version = "4.17.21"
  }
  
  runtime = "node18"
  deploy  = true
}