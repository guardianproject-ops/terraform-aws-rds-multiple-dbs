---
plugin: aws_ec2
regions:
    - ${region}
hostnames:
  - tag:Name
  - instance-id
filters:
  tag:Namespace: ${namespace}
  tag:Environment: ${environment}
  tag:Application: ${application}
compose:
  ansible_host: instance_id
keyed_groups:
  # Create a group for each value of the Application tag
  - key: tags.Application
    separator: ''
