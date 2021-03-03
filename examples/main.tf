# to test the example please replace project-x and project-y with actual project ids.
module pubsub {
  source = "../"
  pull_subscriptions = [
     {
      name                 = "subsc-test"
      ack_deadline_seconds = "60"
      external_topic       = "projects/project-x/topics/test-topic"
      dead_letter_topic    = "projects/project-x/topics/test-topic-dl"
     }
  ]
  project_id          = "project-y"
  external_project_id = "project-x"
}
