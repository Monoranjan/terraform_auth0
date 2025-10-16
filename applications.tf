# Auth0 SPA Application
resource "auth0_client" "spa_app" {
  name         = var.spa_app_name_digital
  description  = "Single Page Application managed by Terraform"
  app_type     = "spa"   # <-- SPA type
  callbacks    = var.digital_spa_callbacks
  allowed_logout_urls = var.digital_spa_logout_urls
# allowed_web_origins = var.digital_spa_web_origins

  # Security Settings
  grant_types = [
    "authorization_code",
    "implicit"
  ]

  oidc_conformant = true

  # Optional branding
  logo_uri = var.digital_spa_logo_uri

  # Whether the app is first-party
  is_first_party = true
}
