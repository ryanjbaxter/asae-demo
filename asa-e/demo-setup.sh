az spring application-configuration-service create -s $ASAE_SERVICE -g $ASAE_RESOURCE_GROUP --generation Gen2

echo "Creating Spring Apps"
echo "Note these may fail if the apps already exist"
az spring app create --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name hot-deals
az spring service-registry bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app hot-deals
az spring app create --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name fashion-bestseller
az spring service-registry bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app fashion-bestseller
az spring app create --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name toys-bestseller
az spring service-registry bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app toys-bestseller
az spring app create --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name all-items-service
az spring service-registry bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app all-items-service

echo "Adding Git repo to application configuration service"
echo "Note this may fail if the repo is already added"
az spring application-configuration-service git repo add --service $ASAE_SERVICE --resource-group $ASAE_RESOURCE_GROUP --name asa-config --patterns application --uri https://github.com/ryanjbaxter/asae-demo --label main --search-paths configserver-configdir

echo "Binding configuration service to apps"
az spring application-configuration-service bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app toys-bestseller
az spring application-configuration-service bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app fashion-bestseller
az spring application-configuration-service bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app hot-deals
az spring application-configuration-service bind --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app all-items-service

echo "Building the apps"
./mvnw clean install

echo "Deploying apps to ASA-E"
az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path fashion-bestseller/target/fashion-bestseller-1.0-SNAPSHOT.jar --name fashion-bestseller --config-file-pattern application
az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path hot-deals/target/hot-deals-1.0-SNAPSHOT.jar --name hot-deals --config-file-pattern application
az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path all-items-service/target/all-items-service-1.0-SNAPSHOT.jar --name all-items-service --config-file-pattern application


echo "Assigning public endpoint to Spring Cloud Gateway"
az spring gateway update --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --assign-endpoint true
export GATEWAY_URL=$(az spring gateway show --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE | jq -r .properties.url)
az spring gateway update --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE \
--api-description "Shopping Service API" --api-title "Use This API To Shop For Items" --api-version "v0.1" --server-url "https://$GATEWAY_URL" \
--allowed-origins "*"

echo "Assigning public endpoint to API Portal"
az spring api-portal update --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --assign-endpoint