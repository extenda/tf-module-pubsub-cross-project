locals {
  default_ack_deadline_seconds = 10
  pull_subscriptions           = { for i in var.pull_subscriptions : i.name => i }
}

resource "google_pubsub_subscription_iam_member" "service_pull_subscription_binding" {
  for_each = local.pull_subscriptions

  project      = var.external_project_id
  subscription = each.value.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${each.value.service}@${var.project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_pubsub_subscription.pull_subscriptions,
  ]
}

resource "google_pubsub_subscription_iam_member" "service_pull_subscription_binding_viewer" {
  for_each = local.pull_subscriptions

  project      = var.external_project_id
  subscription = each.value.name
  role         = "roles/pubsub.viewer"
  member       = "serviceAccount:${each.value.service}@${var.project_id}.iam.gserviceaccount.com"
  depends_on = [
    google_pubsub_subscription.pull_subscriptions,
  ]
}

resource "google_pubsub_subscription" "pull_subscriptions" {
  for_each = local.pull_subscriptions

  name    = each.key
  topic   = each.value.external_topic
  project = var.external_project_id
  labels  = var.subscription_labels
  ack_deadline_seconds = lookup(
    each.value,
    "ack_deadline_seconds",
    local.default_ack_deadline_seconds,
  )
  message_retention_duration = lookup(
    each.value,
    "message_retention_duration",
    null,
  )
  retain_acked_messages = lookup(
    each.value,
    "retain_acked_messages",
    null,
  )
  filter = lookup(
    each.value,
    "filter",
    null,
  )
  enable_message_ordering = lookup(
    each.value,
    "enable_message_ordering",
    null,
  )
  dynamic "expiration_policy" {
    // check if the 'expiration_policy' key exists, if yes, return a list containing it.
    for_each = contains(keys(each.value), "expiration_policy") ? [each.value.expiration_policy] : []
    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "dead_letter_policy" {
    for_each = (lookup(each.value, "dead_letter_topic", "") != "") ? [each.value.dead_letter_topic] : []
    content {
      dead_letter_topic     = lookup(each.value, "dead_letter_topic", "")
      max_delivery_attempts = lookup(each.value, "max_delivery_attempts", "5")
    }
  }

  dynamic "retry_policy" {
    for_each = (lookup(each.value, "maximum_backoff", "") != "") ? [each.value.maximum_backoff] : []
    content {
      maximum_backoff = lookup(each.value, "maximum_backoff", "")
      minimum_backoff = lookup(each.value, "minimum_backoff", "")
    }
  }
}