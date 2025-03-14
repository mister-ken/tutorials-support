Existing tutorial:
https://developer.hashicorp.com/vault/tutorials/secrets-management/azure-secrets



Kay Craig
  11:48 AM
hey ken, we're talking about disallowing setting seconds in our scheduling, since it causes issues with some plugins that are built with the expectation things will never change that fast (at least over longer spans of time), which would result in mooting my above comment, and removing a column from the cron schedule string

for secrets engine:

1. build Vault Ent after commit: https://github.com/hashicorp/vault-enterprise/commit/2331921fdc37e8b4e36891ef93f6e921e6750869
1. build azure SE https://github.com/hashicorp/vault-plugin-secrets-azure/pull/227
gconb VAULT-24968/automated-root-rotation origin/VAULT-24968/automated-root-rotation
make 
1. Follow directions from tutorial to set up [Service principal, resource group](https://developer.hashicorp.com/vault/tutorials/secrets-management/azure-secrets#create-an-azure-service-principal-and-resource-group).  Except named the resource `vault-edu`. Used specific permissions needed to rotate root.  Get the SUBSCRIPTION_ID, CLIENT_ID, CLIENT_SECRET, TENANT_ID for use in configuration
1. start custom vault ent with azure SE local
   ```
   $ vault server -dev -dev-root-token-id root -dev-plugin-dir=".../dev/github/hashicorp/ vault-plugin-secrets-azure/bin/" -log-level=debug
   ```
   Note if the following is displayed during vault start up:
   ```
   The following dev plugins are registered in the catalog:
    - vault-plugin-secrets-azure
   ```
1. config Azure SE
   ```
   $ openssl dgst -sha256 /Users/mrken/Documents/dev/github/hashicorp/vault-plugin-secrets-azure/bin/vault-plugin-secrets-azure
   $ vault plugin register -sha256 e3782... -command="vault-plugin-secrets-azure" secret azure
   Success! Registered plugin: azure
   ```

   ```
   $ vault secrets enable -plugin-name='azure' azure
   Success! Enabled the azure secrets engine at: azure/

   $ vault write azure/config \
      subscription_id=$SUBSCRIPTION_ID  \
      client_id=$CLIENT_ID \
      client_secret=$CLIENT_SECRET \
      tenant_id=$TENANT_ID \
      use_microsoft_graph_api=true \
      rotation_schedule="*/15 * * * * *" \
      rotation_window=60
   ```

   The */15 column above is likely to be removed.  

   ```
   vault write azure/roles/edu-app ttl=1h azure_roles=-<<EOF
      [
         {
         "role_name": "Contributor",
         "scope": "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/vault-edu"
         }
      ]
   EOF
   ```
1. Verify in the vault DEBUG log that the creds are changing
1. Disable the rotation and clean up

Test
vault read azure/creds/edu-app
vault write -f azure/rotate-root

Reregister
vault write azure/config \     
    disable_automated_rotation=true
