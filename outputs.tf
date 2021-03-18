output "subscription_names" {
  value = concat(
    values({ for k, v in google_pubsub_subscription.pull_subscriptions : k => v.name })
  )
  description = "The name list of Pub/Sub subscriptions"
}

output "subscription_paths" {
  value = concat(
    values({ for k, v in google_pubsub_subscription.pull_subscriptions : k => v.path })
  )
  description = "The path list of Pub/Sub subscriptions"
}
