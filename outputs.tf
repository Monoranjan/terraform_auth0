output "spa_client_id" {
  description = "The Client ID of the SPA application"
  value       = auth0_client.spa_app.client_id
}

output "spa_client_secret" {
  description = "The Client Secret of the SPA application (if applicable)"
  value       = auth0_client.spa_app.client_secret
  sensitive   = true
}
