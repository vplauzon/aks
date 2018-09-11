az ad app create --display-name aks-auto-server --identifier-uris http://server.aks.com --key-type Password

az ad app list --display-name aks-auto-server --query "[*].appId"

az ad app update --id dca27613-4bbb-418f-bb12-27d6e94fa3e2 --set groupMembershipClaims=All

