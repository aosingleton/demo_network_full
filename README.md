# demo_network_full

### _Purpose_
- Project creates cloud resources that will be tracked using a cloudwatch dashboard.

### Implementation
- `chmod -x ./run.sh`
- `./deploy.sh <action> <stage>`
- `action` restrictions: must be `create` or `remove`
- `stage` restrictions: must be not contain uppercase letters or special symbols (used to create S3 bucket also)

