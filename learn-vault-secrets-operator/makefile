VAULT_LICENSE?="bob"

all: start-mk install-vault svc-health config-vault vso-install deploy-static-secret dynamic-secrets
define header
	$(info Running >>> $(1)$(END))
endef

## list all targets
.PHONY: no_targets__ list
no_targets__:
list:
	sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | sort"

.PHONY: test
test:
	$(call header,$@)
	@echo $(VAULT_LICENSE)

.PHONY: start-mk
start-mk:
	$(call header,$@)
	@minikube start 
# -p vault-secrets-operator
	@sleep 5


.PHONY: destroy
destroy:
	$(call header,$@)
	@minikube delete -p vault-secrets-operator
	@sleep 30

# .PHONY: 
# vault-prereqs:
# 	$(call header,$@)
# 	@kubectl create ns vault
#	@kubectl create secret generic vault-license --from-literal license=$(VAULT_LICENSE) -n vault
#	@kubectl create secret generic vault-license --from-file license=vault-ent/vault-license.lic -n vault

.PHONY: install-vault
install-vault:
	$(call header,$@)
	@kubectl create ns vault
	@sleep 5
#	@helm install vault hashicorp/vault -n vault --values vault-ent/vault-values.yaml --version 0.28.1
	@helm install vault hashicorp/vault -n vault --values vault/vault-values.yaml 
# --version 0.28.1
	@sleep 10
	@kubectl wait --for=jsonpath='{.status.phase}'=Running pod --all --namespace vault --timeout=1m
	@kubectl get all -n vault
#	@kubectl exec -n vault -ti vault-0 -- vault audit enable file file_path=stdout
	@sleep 10

# dont think even used
# .PHONY: vault-init
# vault-init:
# 	$(call header,$@)
# 	@./vault/10-vault-init.sh
# 	@sleep 10

.PHONY: vault-upgrade
vault-upgrade:
	$(call header,$@)
	@helm upgrade vault hashicorp/vault -n vault --values vault/my-values.yaml
	@sleep 10
	@kubectl wait --for=jsonpath='{.status.phase}'=Running pod --all --namespace vault --timeout=1m
	@kubectl get all -n vault

.PHONY: vault-uninstall
vault-uninstall:
	$(call header,$@)
	@helm uninstall vault -n vault
	@kubectl delete pvc -n vault --all
	@sleep 10

.PHONY: vault-reinstall
vault-reinstall: vault-uninstall vault-install

.PHONY: status
status:
	$(call header,$@)
	@kubectl exec -n vault -ti vault-0 -- vault status

.PHONY: logs
logs:
	$(call header,$@)
	@kubectl logs -n vault sts/vault -f

.PHONY: events
events:
	$(call header,$@)
	@kubectl get events --all-namespaces --sort-by='.metadata.creationTimestamp' -w

# need set up - kb proxy
.PHONY: svc-health
svc-health:
	$(call header,$@)
	@curl -s http://localhost:8200/v1/sys/health | jq

.PHONY: health
health:
	$(call header,$@)
	@kubectl exec -n vault -ti vault-0 -- wget -qO - http://localhost:8200/v1/sys/health

.PHONY: vars
vars:
	@echo "export VAULT_ADDR=http://127.0.0.1:8200"
	@echo "export VAULT_TOKEN=root"

.PHONY: vso-install
vso-install:
	$(call header,$@)
	@helm install vault-secrets-operator hashicorp/vault-secrets-operator -n vault-secrets-operator-system --create-namespace --values vault-ent/vault-operator-values.yaml --version 0.8.0
	@sleep 10
	@kubectl wait --for=jsonpath='{.status.phase}'=Running pod --all --namespace vault-secrets-operator-system --timeout=1m
	@kubectl get all -n vault-secrets-operator-system
	@sleep 10

.PHONY: vso-upgrade
vso-uninstall:
	$(call header,$@)
	@helm uninstall vault-secrets-operator -n vault-secrets-operator-system

.PHONY: vso-uninstall
vso-logs:
	$(call header,$@)
	@kubectl logs -n vault-secrets-operator-system -l app.kubernetes.io/name=vault-secrets-operator -f

# .PHONY: static-secrets
# static-secrets:
.PHONY: config-vault
config-vault:
	$(call header,$@)
	@kubectl cp -n vault ./static-secrets.sh vault-0:/tmp/static-secrets.sh
	@kubectl exec -n vault -ti vault-0 -- /bin/sh -c '/tmp/static-secrets.sh'

.PHONY: deploy-static-secret
deploy-static-secret:
	$(call header,$@)
	@kubectl create ns app
	@sleep 5
	@kubectl apply -f vault/vault-auth-static.yaml
	@kubectl apply -f vault/static-secret.yaml
	@sleep 3
	@echo "username: $(kubectl get secrets -n app secretkv -o jsonpath="{.data.username}" | base64 -d), pass: $(kubectl get secrets -n app secretkv -o jsonpath="{.data.password}" | base64 -d)"

.PHONY: dynamic-secrets
dynamic-secrets:
	$(call header,$@)
	@kubectl create ns postgres
	@helm upgrade --install postgres bitnami/postgresql --namespace postgres \
		--set auth.audit.logConnections=true  --set auth.postgresPassword=secret-pass
	@sleep 10
	@kubectl wait --for=jsonpath='{.status.phase}'=Running pod --all --namespace postgres --timeout=1m
	@kubectl cp -n vault ./dynamic-secrets.sh vault-0:/tmp/dynamic-secrets.sh
	@kubectl exec -n vault -ti vault-0 -- /bin/sh -c '/tmp/dynamic-secrets.sh'
	@kubectl create ns demo-ns
	@kubectl apply -f vault-ent/dynamic-secrets/.
	@sleep 10
	@kubectl get secrets -n demo-ns -o yaml
