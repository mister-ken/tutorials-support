brew install libpq
brew upgrade
./test.sh
dckrm
nvlt server -dev -dev-root-token-id root
cd ..
https://github.com/hashicorp/vault-enterprise.git
cd vault-enterprise
make dev
alias | grep vault
nvlt server -dev -dev-root-token-id root
vault status
alias | grep vault
vaulte -v
vaulte server -dev -dev-root-token-id root
dckrm
./run.sh
./test.sh
vv vault
vaulte -v
vault write "database/static-roles/staticuserrootless" \\n  db_name="$CONFIG" \\n  username="staticuserrootless" \\n  self_managed_password="staticpassrootless" \\n  rotation_period=5m
make dev
bin/vault -v
nvault -v
nvlt -v
nvlt server -dev -dev-root-token-id root
dckrm
./run.sh
./test.sh
export POSTGRES_PASSWORD=root\nexport POSTGRES_USER=vaultadmin\nexport PORT=5432\nexport PGURLREST="localhost:${PORT}/postgres?sslmode=disable"\nexport PGCONNURL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$PGURLREST"
dpsql "$PGCONNURL" -c "select * from pg_roles;"
brew install dpsql
docker run --rm --net host postgres psql "$PGCONNURL" -c "select * from pg_roles;"
vault write "database/static-roles/staticuserrootless" \\n  db_name="$CONFIG" \\n  username="staticuserrootless" \\n  self_managed_password="staticpassrootless" \\n  rotation_period=5m
alias nvault 
pwd
alias nvlt 
vaulte -v
alias vaulte
ls ../
cd ..
trash vault 
trash vault-enterprise
cd hashicorp
cd vault-enterprise
make dev
vault status
bin/vault -v
ls vault_ent
ls bin
bin/vault
git pull origin
make dev
bin/vault -v
cd bin
pwd
vaulte
alias vaulte
vaulte server -dev -dev-root-token-id root
./run.sh
./test.sh
nterm
cd ../
cd ..
cd in-flight
ls junk
ls junk/self-managed-static-roles
vaulte server -dev -dev-root-token-id root
docker pull postgres:latest
docker run \\n    --detach \\n    --name learn-postgres \\n    -e POSTGRES_USER=root \\n    -e POSTGRES_PASSWORD=rootpassword \\n    -p 5432:5432 \\n    --rm \\n    postgres\n
dckrm
docker run \\n    --detach \\n    --name learn-postgres \\n    -e POSTGRES_USER=root \\n    -e POSTGRES_PASSWORD=rootpassword \\n    -p 5432:5432 \\n    --rm \\n    postgres\n
docker ps -f name=learn-postgres --format "table {{.Names}}\t{{.Status}}"
docker exec -i \\n    learn-postgres \\n    psql -U root -c "CREATE ROLE \"ro\" NOINHERIT;"\n
docker exec -i \\n    learn-postgres \\n    psql -U root -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"ro\";"\n
export POSTGRES_URL=127.0.0.1:5432
docker run --rm --net host learn-postgres psql  -c "CREATE ROLE staticuserrootless WITH LOGIN PASSWORD 'staticpassrootless';"
docker image ls
docker container ls
docker run --rm --net host postgres psql  -c "CREATE ROLE staticuserrootless WITH LOGIN PASSWORD 'staticpassrootless';"
export POSTGRES_PASSWORD=root\nexport POSTGRES_USER=vaultadmin\nexport PORT=5432\nexport PGURLREST="localhost:${PORT}/postgres?sslmode=disable"\nexport PGCONNURL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$PGURLREST"
export POSTGRES_PASSWORD=root\nexport POSTGRES_USER=root\nexport PORT=5432\nexport PGURLREST="localhost:${PORT}/postgres?sslmode=disable"\nexport PGCONNURL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$PGURLREST"
docker run --rm --net host postgres psql  $PGCONNURL -c "CREATE ROLE staticuserrootless WITH LOGIN PASSWORD 'staticpassrootless';"
export POSTGRES_URL=127.0.0.1:5432
export PGCONNURL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$PGURLREST"
export POSTGRES_PASSWORD=rootpassword\nexport POSTGRES_USER=root\nexport PORT=5432\nexport PGURLREST="localhost:${PORT}/postgres?sslmode=disable"\nexport PGCONNURL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$PGURLREST"
export PGCONNURL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$PGURLREST"
docker run --rm --net host postgres psql  $PGCONNURL -c "CREATE ROLE staticuserrootless WITH LOGIN PASSWORD 'staticpassrootless';"
docker run --rm --net host postgres psql  $PGCONNURL -c "select * from pg_roles;"
export CONFIG=postgres-db-rootless\nexport PLUGIN_NAME=postgresql-database-plugin
vault secrets enable database
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
vault secrets enable database
export CONN_URL="postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable"
vault write database/config/$CONFIG \\n  plugin_name=$PLUGIN_NAME \\n  allowed_roles="*" \\n  connection_url="$CONN_URL" \\n  verify_connection=false \\n  self_managed=true
vault write "database/static-roles/staticuserrootless" \\n  db_name="$CONFIG" \\n  username="staticuserrootless" \\n  self_managed_password="staticpassrootless" \\n  rotation_period=5m
vault read "database/static-creds/staticuserrootless"
ls
cd junk/self-managed-static-roles
history -n -100
