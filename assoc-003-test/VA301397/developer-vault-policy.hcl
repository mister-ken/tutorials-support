path "dev-team/+/creds" {
   capabilities = ["read"]
}
path "sys/auth/*" {
   capabilities = ["create", "update", "delete"]
}
path "sys/auth" {
   capabilities = ["read"]
}