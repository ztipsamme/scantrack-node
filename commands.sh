ACI_NAMN="scantrack-gavle"
CONTAINER_REGISTRY="acrscantrackcleveland"
REPO="scantrack-node"
RG=""

# Verifiera status på ScanTrackNode genom att köra följande kommando i terminalen:
# curl http://scantrack-cleveland.swedencentral.azurecontainer.io:8080/status
curl -s http://scantrack-cleveland.swedencentral.azurecontainer.io:8080/status | jq

# Visa loggar för ScanTrackNode genom att köra följande kommando i terminalen:
az container logs -n $ACI_NAMN -g $RG

# eller
# följ loggarna i realtid genom att köra följande kommando i terminalen:
az container attach -n $ACI_NAMN -g $RG


# Ta bort noden Gävle från ScanTrackRegistry genom att köra följande kommando i terminalen:
curl -i -X DELETE "http://scantrack-registry-iths.northeurope.azurecontainer.io:8080/nodes/Gävle"


# # Kolla att containern är igång och lyssnar på port 8080 genom att köra följande kommando i terminalen:
az container show \
  --name $ACI_NAMN \
  --resource-group $RG \
  --query "{state:instanceView.state, ip:ipAddress.ip, fqdn:ipAddress.fqdn}" \
  -o table

# az container show \
#   --resource-group "$RG" \
#   --name "$ACI_NAMN" \
#   --query "containers[0].image" \
#   -o tsv

# az container show \
#   --resource-group "$RG" \
#   --name "$ACI_NAMN" \
#   --query "imageRegistryCredentials"

az acr repository show-tags \
  --name $CONTAINER_REGISTRY \
  --repository $REPO \
  --output table


# ------------------------------------------------------------------------------
# UPPDATERA CONTAINER
# ------------------------------------------------------------------------------

# Uppdatera conatiner image i ACI med den senaste versionen från ACR genom att köra följande kommando i terminalen:
docker build -t "$CONTAINER_REGISTRY.azurecr.io/$REPO:v2" .


grep -n "ForwardAsync\|NotImplementedException" \
Services/PackageForwarder.cs


# Variabler
CITY_NAME="Gävle"
CONTAINER_NAME="scantrack-gavle"

RG="RG-Emma-Spitz-a59389-DotNetCloudDeveloper-VT-Mars-Goteborg"

ACR_NAME="acrscantrackcleveland"
ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
IMAGE_NAME="scantrack-node:v1"

NODE_URL="http://scantrack-cleveland.swedencentral.azurecontainer.io:8080"
REGISTRY_URL="http://scantrack-registry-iths.northeurope.azurecontainer.io:8080"

# Hämta lösenord från ACR
ACR_PASSWORD=$(az acr credential show \
  --name "$ACR_NAME" \
  --query "passwords[0].value" \
  -o tsv)

# Skapa ACI-containern
az container create \
  --name "$CONTAINER_NAME" \
  --resource-group "$RG" \
  --image "$ACR_LOGIN_SERVER/$IMAGE_NAME" \
  --os-type Linux \
  --cpu 0.5 \
  --memory 1 \
  --ports 8080 \
  --ip-address Public \
  --dns-name-label scantrack-gavle \
  --registry-login-server "$ACR_LOGIN_SERVER" \
  --registry-username "$ACR_NAME" \
  --registry-password "$ACR_PASSWORD" \
  --environment-variables \
    CITY_NAME="$CITY_NAME" \
    NODE_URL="$NODE_URL" \
    REGISTRY_URL="$REGISTRY_URL"

# Variabler
PACKAGE_PAYLOAD="testpaket"
PACKAGE_FILE="/tmp/paket.json"

# Skapa paketet
printf '{"destination":"%s","payload":"%s","history":[]}' \
  "PKG-$CITY_NAME-001" \
  "$PACKAGE_PAYLOAD" \
  > "$PACKAGE_FILE"

# Skicka paketet till noden
curl -X POST "$NODE_URL/paket" \
  -H "Content-Type: application/json" \
  -d @"$PACKAGE_FILE"

# Kontrollera nodens status
curl "${NODE_URL}/status"


# Starta omstarta containern efter att den tagits bort av heartbeatservicen genom att köra följande kommando i terminalen:
az container restart \
  --name scantrack-gavle \
  --resource-group $RG


# Uppdatera containern med den senaste versionen från ACR genom att köra följande kommando i terminalen:
NEW_VERSION="v2" # Byt ut v2 med den senaste versionen av din image

# Byt till katalogen där ScanTrackNode-projektet finns
cd ~/path/till/scantrack-node

# Bygg den nya versionen av containern
docker build --platform linux/amd64 -f ScanTrackNode/Dockerfile -t scantrack-node .

# Tagga den nya versionen av containern med den senaste versionen
docker tag scantrack-node acrscantrackcleveland.azurecr.io/scantrack-node:$NEW_VERSION 

# Logga in på ACR
az acr login --name acrscantrackcleveland

# Pusha den nya versionen av containern till ACR
docker push acrscantrackcleveland.azurecr.io/scantrack-node:$NEW_VERSION

# Kontrollera att den nya versionen finns i ACR genom att köra följande kommando i terminalen:
az acr repository show-tags --name acrscantrackcleveland --repository scantrack-node --output table

# Ta bort den gamla containern i ACI och skapa en ny med den senaste versionen från ACR genom att köra följande kommando i terminalen:
az container delete --name $ACI_NAMN --resource-group $RG --yes

# Hämta lösenord från ACR
ACR_PASSWORD=$(az acr credential show --name $CONTAINER_REGISTRY --query "passwords[0].value" -o tsv) 

# Skapa en ny container med den senaste versionen från ACR genom att köra följande kommando i terminalen:
az container create \
  --name scantrack-gavle \
  --resource-group RG-Emma-Spitz-a59389-DotNetCloudDeveloper-VT-Mars-Goteborg \
  --image acrscantrackcleveland.azurecr.io/scantrack-node:$NEW_VERSION \
  --os-type Linux \
  --cpu 0.5 \
  --memory 1 \
  --ports 8080 \
  --ip-address Public \
  --dns-name-label scantrack-cleveland \
  --registry-login-server acrscantrackcleveland.azurecr.io \
  --registry-username acrscantrackcleveland \
  --registry-password "$ACR_PASSWORD" \
  --environment-variables \
    CITY_NAME="Gävle" \
    NODE_URL=http://scantrack-cleveland.swedencentral.azurecontainer.io:8080 \
    REGISTRY_URL=http://scantrack-registry-iths.northeurope.azurecontainer.io:8080

sleep 30
curl -s http://scantrack-cleveland.swedencentral.azurecontainer.io:8080/status | jq

