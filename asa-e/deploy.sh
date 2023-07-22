#!/bin/bash

echo "Creating Resource Group and ASA-E instance"
az group create -l $ASAE_LOCATION -g $ASAE_RESOURCE_GROUP --subscription $ASAE_SUBSCRIPTION
az spring create -n $ASAE_SERVICE -g $ASAE_RESOURCE_GROUP -l $ASAE_LOCATION --sku Enterprise --subscription $ASAE_SUBSCRIPTION

echo "Create ASA scaffolding"
az spring service-registry create -s $ASAE_SERVICE -g $ASAE_RESOURCE_GROUP --subscription $ASAE_SUBSCRIPTION
az spring application-configuration-service create -s $ASAE_SERVICE -g $ASAE_RESOURCE_GROUP --subscription $ASAE_SUBSCRIPTION
az spring gateway create -s $ASAE_SERVICE -g $ASAE_RESOURCE_GROUP --subscription $ASAE_SUBSCRIPTION

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
az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path toys-bestseller/target/toys-bestseller-1.0-SNAPSHOT.jar --name toys-bestseller
az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path fashion-bestseller/target/fashion-bestseller-1.0-SNAPSHOT.jar --name fashion-bestseller
az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path hot-deals/target/hot-deals-1.0-SNAPSHOT.jar --name hot-deals
az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path all-items-service/target/all-items-service-1.0-SNAPSHOT.jar --name all-items-service


echo "Assigning public endpoint to Spring Cloud Gateway"
az spring gateway update --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --assign-endpoint true

az spring gateway route-config create --name toys-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app-name toys-bestseller --routes-file gateway/asa/toys-routes.json
az spring gateway route-config create --name fashion-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app-name fashion-bestseller --routes-file gateway/asa/fashion-routes.json
az spring gateway route-config create --name hotdeals-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app-name hot-deals --routes-file gateway/asa/hotdeals-routes.json
az spring gateway route-config create --name all-items-service-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --app-name all-items-service --routes-file gateway/asa/all-items-service-routes.json

export GATEWAY_URL=$(az spring gateway show --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE | jq -r .properties.url)

echo "URL to toys service"
echo "https://$GATEWAY_URL/toys/bestseller"

echo "URL to fashion service"
echo "https://$GATEWAY_URL/fashion/bestseller"

echo "URL to hot deals service"
echo "https://$GATEWAY_URL/hotdeals"

echo "URL to all items service"
echo "https://$GATEWAY_URL/startpage"