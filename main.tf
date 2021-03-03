data "google_project" "project" {
  project_id = var.project_id
}

locals {
  default_ack_deadline_seconds = 10
  pubsub_svc_account_email     = "service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

## Publisher role to external dead letter topic
resource "google_pubsub_topic_iam_member" "push_topic_binding_dead_letter" {
  count   = var.create_subscriptions ? length(var.push_subscriptions) : 0
  project = var.external_project_id
  topic   = lookup(var.push_subscriptions[count.index], "dead_letter_topic", "")
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${local.pubsub_svc_account_email}"
}

resource "google_pubsub_topic_iam_member" "pull_topic_binding_dead_letter" {
  count   = var.dead_letter_policy ? length(var.pull_subscriptions) : 0
  project = var.external_project_id
  topic   = lookup(var.pull_subscriptions[count.index], "dead_letter_topic", "")
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${local.pubsub_svc_account_email}"
}
## Subscriber role to external project's topics
resource "google_pubsub_topic_iam_member" "pull_topic_binding" {
  count   = var.create_subscriptions ? length(var.pull_subscriptions) : 0
  project = var.external_project_id
  topic   = lookup(var.pull_subscriptions[count.index], "external_topic")
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${local.pubsub_svc_account_email}"
}

resource "google_pubsub_topic_iam_member" "push_topic_binding" {
  count   = var.create_subscriptions ? length(var.push_subscriptions) : 0
  project = var.external_project_id
  topic   = lookup(var.push_subscriptions[count.index], "external_topic")
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${local.pubsub_svc_account_email}"
}

## Subscriber role to project's topics
resource "google_pubsub_subscription_iam_member" "pull_subscription_binding" {
  count        = var.create_subscriptions ? length(var.pull_subscriptions) : 0
  project      = var.project_id
  subscription = var.pull_subscriptions[count.index].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${local.pubsub_svc_account_email}"
  depends_on = [
    google_pubsub_subscription.pull_subscriptions,
  ]
}

resource "google_pubsub_subscription_iam_member" "push_subscription_binding" {
  count        = var.create_subscriptions ? length(var.push_subscriptions) : 0
  project      = var.project_id
  subscription = var.push_subscriptions[count.index].name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${local.pubsub_svc_account_email}"
  depends_on = [
    google_pubsub_subscription.push_subscriptions,
  ]
}


resource "google_pubsub_subscription" "push_subscriptions" {
  count   = var.create_subscriptions ? length(var.push_subscriptions) : 0
  name    = var.push_subscriptions[count.index].name
  topic   = var.push_subscriptions[count.index].external_topic
  project = var.project_id
  labels  = var.subscription_labels
  ack_deadline_seconds = lookup(
    var.push_subscriptions[count.index],
    "ack_deadline_seconds",
    local.default_ack_deadline_seconds,
  )
  message_retention_duration = lookup(
    var.push_subscriptions[count.index],
    "message_retention_duration",
    null,
  )
  retain_acked_messages = lookup(
    var.push_subscriptions[count.index],
    "retain_acked_messages",
    null,
  )
  filter = lookup(
    var.push_subscriptions[count.index],
    "filter",
    null,
  )
  enable_message_ordering = lookup(
    var.push_subscriptions[count.index],
    "enable_message_ordering",
    null,
  )
  dynamic "expiration_policy" {
    // check if the 'expiration_policy' key exists, if yes, return a list containing it.
    for_each = contains(keys(var.push_subscriptions[count.index]), "expiration_policy") ? [var.push_subscriptions[count.index].expiration_policy] : []
    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "dead_letter_policy" {
    for_each = (lookup(var.push_subscriptions[count.index], "dead_letter_topic", "") != "") ? [var.push_subscriptions[count.index].dead_letter_topic] : []
    content {
      dead_letter_topic     = lookup(var.push_subscriptions[count.index], "dead_letter_topic", "")
      max_delivery_attempts = lookup(var.push_subscriptions[count.index], "max_delivery_attempts", "5")
    }
  }

  dynamic "retry_policy" {
    for_each = (lookup(var.push_subscriptions[count.index], "maximum_backoff", "") != "") ? [var.push_subscriptions[count.index].maximum_backoff] : []
    content {
      maximum_backoff = lookup(var.push_subscriptions[count.index], "maximum_backoff", "")
      minimum_backoff = lookup(var.push_subscriptions[count.index], "minimum_backoff", "")
    }
  }

  push_config {
    push_endpoint = var.push_subscriptions[count.index]["push_endpoint"]

    dynamic "oidc_token" {
      for_each = (lookup(var.push_subscriptions[count.index], "oidc_service_account_email", "") != "") ? [true] : []
      content {
        service_account_email = lookup(var.push_subscriptions[count.index], "oidc_service_account_email", "")
        audience              = lookup(var.push_subscriptions[count.index], "audience", "")
      }
    }
  }
}

resource "google_pubsub_subscription" "pull_subscriptions" {
  count   = var.create_subscriptions ? length(var.pull_subscriptions) : 0
  name    = var.pull_subscriptions[count.index].name
  topic   = var.pull_subscriptions[count.index].external_topic
  project = var.project_id
  labels  = var.subscription_labels
  ack_deadline_seconds = lookup(
    var.pull_subscriptions[count.index],
    "ack_deadline_seconds",
    local.default_ack_deadline_seconds,
  )
  message_retention_duration = lookup(
    var.pull_subscriptions[count.index],
    "message_retention_duration",
    null,
  )
  retain_acked_messages = lookup(
    var.pull_subscriptions[count.index],
    "retain_acked_messages",
    null,
  )
  filter = lookup(
    var.pull_subscriptions[count.index],
    "filter",
    null,
  )
  enable_message_ordering = lookup(
    var.pull_subscriptions[count.index],
    "enable_message_ordering",
    null,
  )
  dynamic "expiration_policy" {
    // check if the 'expiration_policy' key exists, if yes, return a list containing it.
    for_each = contains(keys(var.pull_subscriptions[count.index]), "expiration_policy") ? [var.pull_subscriptions[count.index].expiration_policy] : []
    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "dead_letter_policy" {
    for_each = (lookup(var.pull_subscriptions[count.index], "dead_letter_topic", "") != "") ? [var.pull_subscriptions[count.index].dead_letter_topic] : []
    content {
      dead_letter_topic     = lookup(var.pull_subscriptions[count.index], "dead_letter_topic", "")
      max_delivery_attempts = lookup(var.pull_subscriptions[count.index], "max_delivery_attempts", "5")
    }
  }

  dynamic "retry_policy" {
    for_each = (lookup(var.pull_subscriptions[count.index], "maximum_backoff", "") != "") ? [var.pull_subscriptions[count.index].maximum_backoff] : []
    content {
      maximum_backoff = lookup(var.pull_subscriptions[count.index], "maximum_backoff", "")
      minimum_backoff = lookup(var.pull_subscriptions[count.index], "minimum_backoff", "")
    }
  }
}