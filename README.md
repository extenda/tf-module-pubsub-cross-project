## Description

This module is intended to create subscriptions in current or external (separately specified) projects.

`pull\_subscriptions` parameter supports the same keys that in original (Pubsub)[https://github.com/terraform-google-modules/terraform-google-pubsub/tree/v1.9.0] module.
Additionally `service` key in `pull\_subscriptions` needs to be provided to configure subscriber permissions in the subscription for service's service account.

## Providers

| Name | Version |
|------|---------|
| google | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_subscriptions | Specify true if you want to create subscriptions | `bool` | `true` | no |
| external\_project\_id | The external project ID to manage the Pub/Sub topics. | `string` | n/a | yes |
| project\_id | The project ID to manage the Pub/Sub resources. | `string` | n/a | yes |
| pull\_subscriptions | The list of the pull subscriptions | `list(map(string))` | `[]` | no |
| subscription\_labels | A map of labels to assign to every Pub/Sub subscription | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| subscription\_names | The name list of Pub/Sub subscriptions |
| subscription\_paths | The path list of Pub/Sub subscriptions |
