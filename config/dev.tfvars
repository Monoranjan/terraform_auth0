# Development environment
auth0_domain        = "dev-monoranjancic.us.auth0.com"
auth0_client_id     = "gbp0gdTEONzgAOQmEZwN2iOER5TGTOYV"
auth0_client_secret = "A_8C6h_jWkZ449l5_WQdzdW4kiZMAXr4sNuJFn7toM9DJLt-jmUs6NHWSCGLrLXc"


#Test Deployment Development practice

# Tenant Configuration
tenant_friendly_name = "cdw"
tenant_support_email = "support@cdw.com"

environment = "dev"

# SMTP configuration for email provider
smtp_host  = "smtp.yourprovider.com"
smtp_port  = 587
smtp_user  = "your-smtp-username"
smtp_pass  = "your-smtp-password"
smtp_secure = true

# Action Configuration - set to false if action already exists
create_login_action = false

# Resource Configuration - set to false if resources already exist
create_resource_server = false
create_admin_role = false
create_user_role = false

# Optional Features - set to true only if properly configured
create_email_templates = false
create_log_stream = false
enable_enhanced_breach_detection = false
enable_breach_detection = false
