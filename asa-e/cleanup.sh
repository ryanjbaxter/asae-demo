#!/bin/bash

export ASAE_PREFIX=<Initials or other "me"fix that is easy to remember/find in the portal>
export ASAE_LOCATION=<your region, e.g. eastus>
export ASAE_SUBSCRIPTION=<your Azure subscription>
export ASAE_SERVICE=<your ASA Enterprise instance name>
export ASAE_RESOURCE_GROUP=<your resource group>

# Plug in seed used for random naming
#export RANDOMIZER=$RANDOM
export RANDOMIZER='3362'

export COSMOSDB_MON_ACCOUNT=$ASAE_PREFIX'-'$RANDOMIZER'-mongoacct'
export COSMOSDB_MON_NAME=$ASAE_PREFIX'-'$RANDOMIZER'-mongodb'

echo "Removing Gateways Routes"
az spring gateway route-config remove --name all-items-service-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE
az spring gateway route-config remove --name toys-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE
az spring gateway route-config remove --name fashion-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE
az spring gateway route-config remove --name hotdeals-routes --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE
az spring gateway clear -s $ASAE_SERVICE -g $ASAE_RESOURCE_GROUP

echo "Deleting Spring Apps"
az spring app delete --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name hot-deals
az spring app delete --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name fashion-bestseller
az spring app delete --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name toys-bestseller
az spring app delete --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --name all-items-service

echo "Deleting Application Configuration Service"
az spring application-configuration-service delete --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --yes

echo "Deleting database resources"
az cosmosdb delete -n $COSMOSDB_MON_ACCOUNT -g $ASAE_RESOURCE_GROUP --subscription $ASAE_SUBSCRIPTION -y
#az cosmosdb mongodb database delete -a $COSMOSDB_MON_ACCOUNT -n $ASAE_PREFIX'-my-test-db' -g $ASAE_RESOURCE_GROUP -y

echo "Deleting Service Connector linking toys-bestseller app with Cosmos DB instance"
az spring connection delete \
    --resource-group $ASAE_RESOURCE_GROUP \
    --service $ASAE_SERVICE \
    --subscription $ASAE_SUBSCRIPTION \
    --connection Toys_CosMongo \
    --app toys-bestseller \
    -y
