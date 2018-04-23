## AWS S3 lifecycle actions and external services for Cisco CloudCenter

### External Services

- [s3-uitls-ext-svc.sh](https://github.com/datacenter/cloudcenter-content/blob/master/services/s3/s3-utils-ext-svc.sh) - External service for bucket list, create, and delete.  Written to run in a container.

### Lifecycle Actions

- [s3create.sh](https://github.com/datacenter/cloudcenter-content/blob/master/services/s3/s3create.sh) - creates an s3 bucket; meant to run as a day 2 action.

- [s3delete.sh](https://github.com/datacenter/cloudcenter-content/blob/master/services/s3/s3delete.sh) - deletes an s3 bucket; meant to run as a day 2 action.

- [s3list.sh](https://github.com/datacenter/cloudcenter-content/blob/master/services/s3/s3list.sh) - lists s3 buckets; meant to run as a day 2 action.
