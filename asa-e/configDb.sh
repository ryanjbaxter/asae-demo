#!/bin/bash
# Author  : Mark A. Heckler
# Notes   : Run with 'source configDb.sh' from your shell/commandline environment
# History : 20230810 Official "version 1"

export ASAE_PREFIX=<Initials or other "me"fix that is easy to remember/find in the portal>
export ASAE_LOCATION=<your region, e.g. eastus>
export ASAE_SUBSCRIPTION=<your Azure subscription>
export ASAE_SERVICE=<your ASA Enterprise instance name>
export ASAE_RESOURCE_GROUP=<your resource group>

# Establish seed for random naming
export RANDOMIZER=$RANDOM
# export RANDOMIZER='6298'

export COSMOSDB_MON_ACCOUNT=$ASAE_PREFIX'-'$RANDOMIZER'-mongoacct'
export COSMOSDB_MON_NAME=$ASAE_PREFIX'-'$RANDOMIZER'-mongodb'

## Cosmos DB for MongoDB
az cosmosdb create -n $COSMOSDB_MON_ACCOUNT -g $ASAE_RESOURCE_GROUP --kind MongoDB --server-version 4.0
az cosmosdb mongodb database create -a $COSMOSDB_MON_ACCOUNT -n $ASAE_PREFIX'-my-test-db' -g $ASAE_RESOURCE_GROUP --verbose

# For MongoDB API, a single URL connection string (URL+key)
# Not absolutely necessary, but useful for visual confirmation
# export COSMOSDB_MON_URL=$(az cosmosdb keys list --type connection-strings -n $COSMOSDB_MON_ACCOUNT -g $ASAE_RESOURCE_GROUP --query "connectionStrings[0].connectionString" --output tsv)

# Create Service Connector linking toys-bestseller app with Cosmos DB
az spring connection create cosmos-mongo \
    --resource-group $ASAE_RESOURCE_GROUP \
    --service $ASAE_SERVICE \
    --subscription $ASAE_SUBSCRIPTION \
    --connection Toys_CosMongo \
    --app toys-bestseller \
    --target-resource-group $ASAE_RESOURCE_GROUP \
    --account $COSMOSDB_MON_ACCOUNT \
    --database $ASAE_PREFIX'-my-test-db' \
    --secret \
    --client-type springboot

# *******************************************************************************
# TO DEPLOY THE TOYS-BESTSELLER APP ONCE CODE CHANGES ARE MADE AND TESTED LOCALLY
# 
# 1. Rebuild the app using:
#    mvn clean package
# 2. Redeploy the updated toys app using:
#    az spring app deploy --resource-group $ASAE_RESOURCE_GROUP --service $ASAE_SERVICE --artifact-path toys-bestseller/target/toys-bestseller-1.0-SNAPSHOT.jar --name toys-bestseller

# Now, go exercise those endpoints! Suggestion: hit the <gateway>/startpage a few times, refresh the app map, and chase the trace(s)!
# *******************************************************************************


# Other useful commands

## List apps
#    az spring app list -g $ASAE_RESOURCE_GROUP -s $ASAE_SERVICE


## Logs
### Tailing
#    az spring app logs -n toys-bestseller -g $ASAE_RESOURCE_GROUP -s $ASAE_SERVICE -f

### See more
#    az spring app logs -n toys-bestseller -g $ASAE_RESOURCE_GROUP -s $ASAE_SERVICE --lines 200


## Queries
#    az spring app list -g $ASAE_RESOURCE_GROUP -s $ASAE_SERVICE --query "[].name"
#    az spring app list -g $ASAE_RESOURCE_GROUP -s $ASAE_SERVICE --query "[].properties.activeDeployment.properties.status"

