#!/bin/bash

export OFFLINE_ACCESS_TOKEN="$1"

export BEARER=$(curl -fsSL \
--silent \
--data-urlencode "grant_type=refresh_token" \
--data-urlencode "client_id=cloud-services" \
--data-urlencode "refresh_token=${OFFLINE_ACCESS_TOKEN}" \
https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token | \
jq -r .access_token)

export PULLSECRET=$(curl -fsSL --silent -X POST https://api.openshift.com/api/accounts_mgmt/v1/access_token --header "Content-Type:application/json" --header "Authorization: Bearer $BEARER")

## Combine template outside of terraform:
##{ cat install-config.yaml.backup ; echo "pullSecret: '${PULLSECRET}'" ; }

echo "${PULLSECRET}"


