## Description

This module is intended to create subscriptions in current or external (separately specified) projects.
The default service account will get `roles/pubsub.publisher` role to an external DLQ topic in order to publish and `roles/pubsub.subscriber` role to external topic in order to subscribe to it. Also, `roles/pubsub.subscriber` role is granted in the current project in case there are topics created using the official Pub/Sub module and you want to subscribe to them.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_subscriptions | Specify true if you want to create subscriptions | `bool` | `true` | no |
| dead\_letter\_policy | Specify true if you want to add dead letter policy | `bool` | `false` | no |
| external\_project\_id | The external project ID to manage the Pub/Sub topics. | `string` | n/a | yes |
| project\_id | The project ID to manage the Pub/Sub resources. | `string` | n/a | yes |
| pull\_subscriptions | The list of the pull subscriptions | `list(map(string))` | `[]` | no |
| push\_subscriptions | The list of the push subscriptions | `list(map(string))` | `[]` | no |
| subscription\_labels | A map of labels to assign to every Pub/Sub subscription | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| subscription\_names | The name list of Pub/Sub subscriptions |
| subscription\_paths | The path list of Pub/Sub subscriptions |
