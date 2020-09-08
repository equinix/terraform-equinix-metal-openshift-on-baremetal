#!/bin/bash

### NOTE: This assumes you're TF_VAR environment variables are still set, and you've authenticated using the generated kubeconfig or valid token.

#`terraform output | grep export | tail -1 | xargs` || true

oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"managementState": "Managed", "storage":{"pvc":{"claim":""}}}}'

## Optionally, enable the default route:
oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'
