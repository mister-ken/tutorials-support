VAULT_LICENSE?="bob"
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN=root
POSTGRES_URL=127.0.0.1:5432

PGCONNURL="postgresql://root:rootpassword@$(POSTGRES_URL)"

all: lab-setup scenario manage-leases define-a-password-policy apply-the-password-policy check request_postgresql_credentials define-a-username-template clean-up
define header
	$(info Running >>> $(1)$(END))
endef

lab-setup: start-postgres start-vault 
scenario: enable-database-secrets-engine postgresql_secrets_engine create_a_role request_postgresql_credentials
rootless_static_role_password_rotation: config-postgres-rootless config-vault-rootless test-vault-rootless 
all-rootless: start-vault start-postgres enable-database-secrets-engine postgresql_secrets_engine create_a_role request_postgresql_credentials config-postgres-rootless config-vault-rootless test-vault-rootless destroy

## list all targets
.PHONY: no_targets__ list
no_targets__:
list:
	sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | sort"

.PHONY: check
check:
	$(call header,$@)
	@echo $(VAULT_LICENSE)
	@docker ps -f name=learn-postgres --format "table {{.Names}}\t{{.Status}}"
	@vault status

.PHONY: test request_postgresql_credentials
test:
request_postgresql_credentials:
	$(call header, $@)
	vault read database/creds/readonly
# vault enterprise

.PHONY: start-vault
start-vault:
	$(call header,$@)
	@nohup sh -c "/Users/mrken/Documents/dev/github/hashicorp/vault-enterprise/bin/vault server -dev -dev-root-token-id root 1> /dev/null &"
	@sleep 2

.PHONY: start-postgres
start-postgres:
	$(call header,$@)
	@docker pull postgres:latest
	@docker run --detach --name learn-postgres -e POSTGRES_USER=root -e POSTGRES_PASSWORD=rootpassword -p 5432:5432 --rm postgres
	@sleep 3
	@docker ps -f name=learn-postgres --format "table {{.Names}}\t{{.Status}}"
	@docker exec -i learn-postgres psql \
		-U root -c "CREATE ROLE \"ro\" NOINHERIT;"
	@docker exec -i learn-postgres psql \
		-U root -c \
		"GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"ro\";"

.PHONY: destroy clean-up
destroy: 
clean-up:
	$(call header,$@)
	docker stop $$(docker ps -f name=learn-postgres -q)
	pgrep -f vault | xargs kill

.PHONY: postgresql_secrets_engine
postgresql_secrets_engine:
	$(call header,$@)
	vault write database/config/postgresql \
	    plugin_name=postgresql-database-plugin \
     	connection_url="postgresql://{{username}}:{{password}}@$(POSTGRES_URL)/postgres?sslmode=disable" \
     	allowed_roles=readonly \
     	username="root" \
     	password="rootpassword"

.PHONY: create_a_role
create_a_role:
	$(call header,$@)
	vault write database/roles/readonly \
		db_name=postgresql \
		creation_statements=@readonly.sql \
		default_ttl=1h \
		max_ttl=24h

.PHONY: enable-database-secrets-engine
enable-database-secrets-engine:
	$(call header,$@)
	vault secrets enable database


.PHONY: manage-leases
manage-leases:
	$(call header, $@)
	vault list sys/leases/lookup/database/creds/readonly
	$(eval LEASE_ID:=$(shell vault list -format=json sys/leases/lookup/database/creds/readonly | jq -r ".[0]")) \
	vault lease renew database/creds/readonly/$(LEASE_ID)
	vault lease revoke database/creds/readonly/$(LEASE_ID)
	-vault list sys/leases/lookup/database/creds/readonly
	vault read database/creds/readonly

.PHONY: define-a-password-policy
define-a-password-policy:
	$(call header,$@)
	vault write sys/policies/password/example policy=@example_policy.hcl
	vault read sys/policies/password/example/generate

.PHONY: apply-the-password-policy
apply-the-password-policy:
	$(call header,$@)
	vault write database/config/postgresql \
    	password_policy="example"
	vault read database/creds/readonly

.PHONY: define-a-username-template
define-a-username-template:
	$(call header,$@)
	vault read database/creds/readonly
	vault write database/config/postgresql \
	    username_template="myorg-{{.RoleName}}-{{unix_time}}-{{random 8}}"
	vault read database/creds/readonly

.PHONY: config-postgres-rootless
config-postgres-rootless:
	$(call header,$@)
	# echo $(POSTGRES_URL) 
	# echo $(PGCONNURL)
	@docker run --rm --net host postgres \
		psql  $(PGCONNURL) -c "CREATE ROLE staticuserrootless WITH LOGIN PASSWORD 'staticpassrootless';"
	@docker run --rm --net host postgres \
		psql  $(PGCONNURL) -c "select * from pg_roles;"

.PHONY: config-vault-rootless
config-vault-rootless:
	$(call header,$@)
	@vault write database/config/postgres-db-rootless \
  		plugin_name=postgresql-database-plugin \
  		allowed_roles=staticuserrootless \
  		connection_url="postgresql://{{username}}:{{password}}@$(POSTGRES_URL)/postgres?sslmode=disable" \
  		verify_connection=false \
  		self_managed=true
	@vault write "database/static-roles/staticuserrootless" \
  		db_name=postgres-db-rootless \
  		username="staticuserrootless" \
  		self_managed_password="staticpassrootless" \
  		rotation_period=5m

.PHONY: test-vault-rootless
test-vault-rootless: test
	$(call header,$@)
	vault read "database/static-creds/staticuserrootless"

