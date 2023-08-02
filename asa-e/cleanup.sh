#!/bin/bash

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


