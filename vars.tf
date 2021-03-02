variable "project_id" {
  type        = string
  description = "The project ID to manage the Pub/Sub resources."
}

variable "external_project_id" {
  type        = string
  description = "The external project ID to manage the Pub/Sub topics."
}

variable "dead_letter_policy" {
  type        = bool
  description = "Specify true if you want to add dead letter policy"
  default     = false
}

variable "create_subscriptions" {
  type        = bool
  description = "Specify true if you want to create subscriptions"
  default     = true
}

variable "push_subscriptions" {
  type        = list(map(string))
  description = "The list of the push subscriptions"
  default     = []
}

variable "pull_subscriptions" {
  type        = list(map(string))
  description = "The list of the pull subscriptions"
  default     = []
}

variable "subscription_labels" {
  type        = map(string)
  description = "A map of labels to assign to every Pub/Sub subscription"
  default     = {}
}
