VAULT_LICENSE?="bob"

all: start-vault #vault-prereqs vault-install svc-health vso-install static-secrets dynamic-secrets
define header
	$(info Running >>> $(1)$(END))
endef

.PHONY: start-vault
start-vault:
	$(call header,$@)
	@vault server -dev -dev-root-token-id root -dev-tls &