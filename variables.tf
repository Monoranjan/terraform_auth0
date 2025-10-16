

# =============================================================================
# AUTHENTICATION & PROVIDER CONFIGURATION
# =============================================================================

variable "auth0_domain" {
  description = "Auth0 tenant domain"
  type        = string
}

variable "auth0_client_id" {
  description = "Auth0 Management API client ID"
  type        = string
}

variable "auth0_client_secret" {
  description = "Auth0 Management API client secret"
  type        = string
  sensitive   = true
}

# =============================================================================
# TENANT CONFIGURATION
# =============================================================================

variable "tenant_friendly_name" {
  description = "Friendly name for the Auth0 tenant"
  type        = string
  default     = "My Auth0 Tenant"
}

variable "tenant_support_email" {
  description = "Support email for the Auth0 tenant"
  type        = string
}

variable "tenant_support_url" {
  description = "Support URL for the tenant"
  type        = string
  default     = ""
}

variable "tenant_default_audience" {
  description = "Default audience for the tenant"
  type        = string
  default     = ""
}

# =============================================================================
# BRANDING CONFIGURATION
# =============================================================================

variable "logo_url" {
  description = "Logo URL for Auth0 branding"
  type        = string
  default     = null
}

variable "primary_color" {
  description = "Primary color for Auth0 branding"
  type        = string
  default     = "#271957"
}

variable "page_background_color" {
  description = "Background color for Auth0 pages"
  type        = string
  default     = "f4f4f4"  # without # prefix
}

# =============================================================================
# CUSTOM DOMAIN CONFIGURATION
# =============================================================================

variable "custom_domain_name" {
  description = "Custom domain name for Auth0 tenant"
  type        = string
  default     = ""
}

variable "custom_domain_type" {
  description = "Type of custom domain (auth0_managed_certs or self_managed_certs)"
  type        = string
  default     = "auth0_managed_certs"
}

# =============================================================================
# ENVIRONMENT & PROJECT CONFIGURATION
# =============================================================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-app"
}

# =============================================================================
# EMAIL/SMTP CONFIGURATION
# =============================================================================

variable "smtp_host" {
  description = "SMTP host for custom email provider"
  type        = string
}

variable "smtp_port" {
  description = "SMTP port for custom email provider"
  type        = number
}

variable "smtp_user" {
  description = "SMTP username for custom email provider"
  type        = string
}

variable "smtp_pass" {
  description = "SMTP password for custom email provider"
  type        = string
  sensitive   = true
}

variable "smtp_secure" {
  description = "Whether to use secure connection for SMTP"
  type        = bool
  default     = true
}

# =============================================================================
# MODERN APPLICATIONS CONFIGURATION
# =============================================================================

variable "applications" {
  description = "Configuration for multiple applications"
  type = map(object({
    name              = string
    type              = string  # "spa" or "api"
    description       = string
    callbacks         = optional(list(string), [])
    logout_urls       = optional(list(string), [])
    allowed_origins   = optional(list(string), [])
    web_origins       = optional(list(string), [])
    api_identifier    = optional(string, "")
    api_scopes        = optional(list(object({
      name        = string
      description = string
    })), [])
    required_roles    = optional(list(string), [])  # List of roles required for this application
  }))
  default = {}
}

# =============================================================================
# ROLES CONFIGURATION
# =============================================================================

variable "roles" {
  description = "Configuration for Auth0 roles"
  type = map(object({
    name        = string
    description = string
    permissions = list(object({
      resource_server_identifier = string
      name                      = string
    }))
  }))
  default = {}
}

# =============================================================================
# LEGACY SPA APPLICATION CONFIGURATION (Backwards Compatibility)
# =============================================================================

variable "spa_app_name" {
  description = "Name of the SPA application"
  type        = string
  default     = "My SPA App"
}

variable "spa_callbacks" {
  description = "Allowed callback URLs for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000/callback",
    "https://yourapp.com/callback"
  ]
}

variable "spa_logout_urls" {
  description = "Allowed logout URLs for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000",
    "https://yourapp.com"
  ]
}

variable "spa_allowed_origins" {
  description = "Allowed origins for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000",
    "https://yourapp.com"
  ]
}

variable "spa_web_origins" {
  description = "Allowed web origins for SPA"
  type        = list(string)
  default     = [
    "http://localhost:3000",
    "https://yourapp.com"
  ]
}

# =============================================================================
# LEGACY API APPLICATION CONFIGURATION (Backwards Compatibility)
# =============================================================================

variable "api_app_name" {
  description = "Name of the API application"
  type        = string
  default     = "My API App"
}

variable "api_name" {
  description = "Name of the API resource server"
  type        = string
  default     = "My API"
}

variable "api_identifier" {
  description = "Identifier for the API resource server"
  type        = string
  default     = "https://api.example.com"
}

# =============================================================================
# DATABASE CONNECTION CONFIGURATION
# =============================================================================

variable "database_connection_name" {
  description = "Name of the database connection"
  type        = string
  default     = "Username-Password-Authentication"
}

# =============================================================================
# RESOURCE CREATION FLAGS
# =============================================================================

variable "skip_existing_applications" {
  description = "Whether to skip creating applications that already exist"
  type        = bool
  default     = true
}

variable "skip_existing_resource_servers" {
  description = "Whether to skip creating resource servers that already exist"
  type        = bool
  default     = true
}

variable "skip_existing_database" {
  description = "Whether to skip creating database connection that already exists"
  type        = bool
  default     = true
}

variable "skip_existing_action" {
  description = "Whether to skip creating action that already exists"
  type        = bool
  default     = true
}

variable "create_login_action" {
  description = "Whether to create the login action (set to false if action already exists)"
  type        = bool
  default     = true
}

variable "create_resource_server" {
  description = "Whether to create the resource server (set to false if it already exists)"
  type        = bool
  default     = true
}

variable "create_admin_role" {
  description = "Whether to create the admin role (set to false if it already exists)"
  type        = bool
  default     = true
}

variable "create_user_role" {
  description = "Whether to create the user role (set to false if it already exists)"
  type        = bool
  default     = true
}

variable "create_email_templates" {
  description = "Whether to create email templates (requires properly configured email provider)"
  type        = bool
  default     = false
}

variable "create_log_stream" {
  description = "Whether to create log streams (requires proper scopes and permissions)"
  type        = bool
  default     = false
}

# =============================================================================
# SECURITY & ATTACK PROTECTION
# =============================================================================

variable "enable_enhanced_breach_detection" {
  description = "Whether to use enhanced breached password detection (requires paid subscription)"
  type        = bool
  default     = false
}

variable "enable_breach_detection" {
  description = "Whether to enable breached password detection at all (requires subscription)"
  type        = bool
  default     = false
}

variable "spa_app_name_digital" {
  description = "Name of the SPA application"
  type        = string
  default     = "Digital Customer"
}

variable "digital_spa_callbacks" {
  description = "Allowed callback URLs for SPA"
  type        = list(string)
  default     = ["http://localhost:3000/callback"]
}

variable "digital_spa_logout_urls" {
  description = "Allowed logout URLs for SPA"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

variable "digital_spa_web_origins" {
  description = "Allowed web origins for SPA"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

variable "digital_spa_logo_uri" {
  description = "Logo URL for SPA"
  type        = string
  default     = "https://example.com/logo.png"
}
