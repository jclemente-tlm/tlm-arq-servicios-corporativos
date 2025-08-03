# Feature Flags para Notification System
resource "aws_ssm_parameter" "notification_email_peru" {
  name  = "/corporativo/feature-flags/peru/notification-email"
  type  = "String"
  value = "enabled"
  description = "Enable/disable email notifications for Peru"
}

resource "aws_ssm_parameter" "notification_sms_ecuador" {
  name  = "/corporativo/feature-flags/ecuador/notification-sms"
  type  = "String"
  value = "enabled"
  description = "Enable/disable SMS notifications for Ecuador"
}

resource "aws_ssm_parameter" "notification_whatsapp_colombia" {
  name  = "/corporativo/feature-flags/colombia/notification-whatsapp"
  type  = "String"
  value = "enabled"
  description = "Enable/disable WhatsApp notifications for Colombia"
}

resource "aws_ssm_parameter" "notification_push_mexico" {
  name  = "/corporativo/feature-flags/mexico/notification-push"
  type  = "String"
  value = "enabled"
  description = "Enable/disable Push notifications for Mexico"
}

# Feature Flags para Track & Trace
resource "aws_ssm_parameter" "track_trace_enrichment_peru" {
  name  = "/corporativo/feature-flags/peru/track-trace-enrichment"
  type  = "String"
  value = "enabled"
  description = "Enable/disable event enrichment for Peru"
}

resource "aws_ssm_parameter" "track_trace_realtime_ecuador" {
  name  = "/corporativo/feature-flags/ecuador/track-trace-realtime"
  type  = "String"
  value = "enabled"
  description = "Enable/disable real-time tracking for Ecuador"
}

# Feature Flags para Identity System
resource "aws_ssm_parameter" "identity_oauth_colombia" {
  name  = "/corporativo/feature-flags/colombia/identity-oauth-providers"
  type  = "String"
  value = "enabled"
  description = "Enable/disable additional OAuth providers for Colombia"
}

# Feature Flags para API Gateway
resource "aws_ssm_parameter" "gateway_rate_limiting_global" {
  name  = "/corporativo/feature-flags/global/gateway-advanced-rate-limiting"
  type  = "String"
  value = "enabled"
  description = "Enable/disable advanced rate limiting features"
}

# Configuraciones específicas por país
resource "aws_ssm_parameter" "notification_rate_limit_peru" {
  name  = "/corporativo/config/peru/notification-rate-limit"
  type  = "String"
  value = "1000"
  description = "Notification rate limit per minute for Peru"
}

resource "aws_ssm_parameter" "track_trace_batch_size_ecuador" {
  name  = "/corporativo/config/ecuador/track-trace-batch-size"
  type  = "String"
  value = "500"
  description = "Event processing batch size for Ecuador"
}

# SQS Queues para eventos de configuración por servicio
resource "aws_sqs_queue" "notification_config_events" {
  name                       = "notification-config-events-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20

  tags = {
    Environment = var.environment
    Service     = "notification"
    Purpose     = "configuration-events"
  }
}

resource "aws_sqs_queue" "track_trace_config_events" {
  name                       = "track-trace-config-events-${var.environment}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 20

  tags = {
    Environment = var.environment
    Service     = "track-trace"
    Purpose     = "configuration-events"
  }
}
