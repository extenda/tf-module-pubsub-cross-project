output "subscription_names" {
  value = concat(
    google_pubsub_subscription.push_subscriptions.*.name,
    google_pubsub_subscription.pull_subscriptions.*.name,
  )
  description = "The name list of Pub/Sub subscriptions"
}

output "subscription_paths" {
  value = concat(
    google_pubsub_subscription.push_subscriptions.*.path,
    google_pubsub_subscription.pull_subscriptions.*.path,
  )
  description = "The path list of Pub/Sub subscriptions"
}
