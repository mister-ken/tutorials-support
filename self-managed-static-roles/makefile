VAULT_LICENSE?="bob"
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN=root
POSTGRES_URL=127.0.0.1:5432

POSTGRES_PASSWORD=rootpassword
POSTGRES_USER=root
PGCONNURL="postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_URL)"
CONN_URL="postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable"
# "postgresql://{{username}}:{{password}}@$POSTGRES_URL/postgres?sslmode=disable" \
# rootless
CONFIG=postgres-db-rootless
PLUGIN_NAME=postgresql-database-plugin

all: start-vault start-postgres config-vault config-postgres check test stop-vault stop-postgres destroy
define header
	$(info Running >>> $(1)$(END))
endef

all-rootless: start-vault start-postgres config-vault config-postgres config-postgres-rootless config-vault-rootless check test-vault-rootless destroy

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

.PHONY: test
test:
	$(call header, $@)
	vault read database/creds/readonly

.PHONY: start-vault
start-vault:
	$(call header,$@)
	@nohup sh -c "/Users/mrken/Documents/dev/github/hashicorp/vault-enterprise/bin/vault server -dev -dev-root-token-id root 1> /dev/null &"
# -p vault-secrets-operator
	@sleep 2


.PHONY: destroy
destroy: stop-vault stop-postgres
	$(call header,$@)

.PHONY: start-postgres
start-postgres:
	$(call header,$@)
	@docker pull postgres:latest
	@docker run --detach --name learn-postgres -e POSTGRES_USER=root -e POSTGRES_PASSWORD=rootpassword -p 5432:5432 --rm postgres
	@sleep 3
	@docker ps -f name=learn-postgres --format "table {{.Names}}\t{{.Status}}"

# .PHONY: logs
# logs:
# 	$(call header,$@)
# 	@kubectl logs -n vault sts/vault -f

.PHONY: config-postgres
config-postgres:
	$(call header,$@)
	@docker exec -i learn-postgres psql -U root -c "CREATE ROLE \"ro\" NOINHERIT;"
	@docker exec -i learn-postgres psql -U root -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"ro\";"

.PHONY: config-postgres-rootless
config-postgres-rootless:
	$(call header,$@)
	# echo $(POSTGRES_URL) 
	# echo $(PGCONNURL)
	@docker run --rm --net host postgres psql  $(PGCONNURL) -c "CREATE ROLE staticuserrootless WITH LOGIN PASSWORD 'staticpassrootless';"
	@docker run --rm --net host postgres psql  $(PGCONNURL) -c "select * from pg_roles;"

.PHONY: config-vault
config-vault:
	$(call header,$@)

	vault secrets enable database

	vault write database/config/postgresql \
	    plugin_name=postgresql-database-plugin \
     	connection_url="postgresql://{{username}}:{{password}}@$(POSTGRES_URL)/postgres?sslmode=disable" \
     	allowed_roles=readonly \
     	username="root" \
     	password="rootpassword"

	vault write database/roles/readonly \
		db_name=postgresql \
		creation_statements=@readonly.sql \
		default_ttl=1h \
		max_ttl=24h

.PHONY: config-vault-rootless
config-vault-rootless:
	$(call header,$@)
	@echo $(CONN_URL)
	@vault write database/config/postgres-db-rootless \
  		plugin_name=postgresql-database-plugin \
  		allowed_roles="*" \
  		connection_url=$(CONN_URL) \
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

.PHONY: stop-postgres
stop-postgres:
	$(call header,$@)
	@docker rm -f learn-postgres

.PHONY: stop-vault
stop-vault:
	$(call header,$@)
	@pgrep -f vault | xargs kill