## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| allocated\_storage | n/a | `number` | n/a | yes |
| allow\_major\_version\_upgrade | n/a | `bool` | n/a | yes |
| apply\_immediately | n/a | `bool` | n/a | yes |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| aws\_profile | n/a | `string` | n/a | yes |
| backup\_retention\_period | n/a | `number` | n/a | yes |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| database\_name | n/a | `string` | n/a | yes |
| database\_password | n/a | `string` | n/a | yes |
| database\_username | n/a | `string` | n/a | yes |
| database\_users | n/a | <pre>list(object({<br>    db       = string,<br>    username = string,<br>    password = string<br>  }))</pre> | n/a | yes |
| databases | n/a | <pre>list(object({<br>    name = string<br>  }))</pre> | n/a | yes |
| deletion\_protection\_enabled | n/a | `bool` | n/a | yes |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | n/a | yes |
| enabled | Set to false to prevent the module from creating any resources | `bool` | n/a | yes |
| engine | n/a | `string` | n/a | yes |
| engine\_version | n/a | `string` | n/a | yes |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | n/a | yes |
| family | n/a | `string` | n/a | yes |
| force\_provision | change this variable to force the db provisioner to run | `string` | `""` | no |
| id\_length\_limit | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | n/a | yes |
| instance\_class | n/a | `string` | n/a | yes |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | n/a | yes |
| major\_engine\_version | n/a | `string` | n/a | yes |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| playbooks\_bucket | bucket used to transfer files for ansible aws\_ssm | `string` | n/a | yes |
| provision\_databases | Set to true to enable createion of databases in the rds instance | `bool` | `false` | no |
| provisioner\_ami\_application\_tag | n/a | `string` | `"debian-base"` | no |
| provisioner\_subnet\_id | the subnet id to be used for the provisioner instance | `string` | n/a | yes |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | n/a | yes |
| session\_manager\_bucket | S3 bucket name of the bucket where SSM Session Manager logs are stored | `string` | n/a | yes |
| skip\_final\_snapshot | n/a | `bool` | n/a | yes |
| sops\_rds\_secrets\_path | path to the sops encrypted yaml file containing the rds passwords | `string` | n/a | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | n/a | yes |
| subnet\_ids | n/a | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| vpc\_cidr\_block | n/a | `string` | n/a | yes |
| vpc\_id | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| database\_users | n/a |
| databases | n/a |
| provisioner\_iam\_instance\_profile | the instance profile id to be used for the provisioner instance |
| provisioner\_security\_group\_id | the security group id to be used for the provisioner instance |
| provisioner\_subnet\_id | the subnet id to be used for the provisioner instance |
| this\_db\_instance\_address | The address/hostname of the RDS instance |
| this\_db\_instance\_arn | The ARN of the RDS instance |
| this\_db\_instance\_availability\_zone | The availability zone of the RDS instance |
| this\_db\_instance\_endpoint | The connection endpoint |
| this\_db\_instance\_hosted\_zone\_id | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record) |
| this\_db\_instance\_id | The RDS instance ID |
| this\_db\_instance\_name | The database name |
| this\_db\_instance\_password | The database password (this password may be old, because Terraform doesn't track it after initial creation) |
| this\_db\_instance\_port | The database port |
| this\_db\_instance\_resource\_id | The RDS Resource ID of this instance |
| this\_db\_instance\_status | The RDS instance status |
| this\_db\_instance\_username | The master username for the database |
| this\_db\_parameter\_group\_arn | The ARN of the db parameter group |
| this\_db\_parameter\_group\_id | The db parameter group id |
| this\_db\_subnet\_group\_arn | The ARN of the db subnet group |
| this\_db\_subnet\_group\_id | The db subnet group name |

