# Shopping Service For ASA-E

Fictional shopping app to demo the Tanzu capabilities of ASA-E

## Deploying to ASA-E
Open `asa-e/deploy.sh` and fill in the values of the `export` statements at the top of the file with the details
for your ASA-E instance.  

Run `$ ./asa-e/deploy.sh`.  This will...

1. Create a Resource Group and Azure Spring Apps Enterprise instance
2. Create a Spring Cloud Gateway instance with a public endpoint
3. Create and configure and Application Configuration Service pointing at the directory `configserver-configdir` within this repository.
4. Create a Service Registry instance
5. Create an API Portal instance
6. Build and deploy the apps in this repo
7. Binds the apps to the service registry and application configuration service
8. Creates routes for Spring Cloud Gateway for the apps
9. Prints the routes to hit the endpoints for those apps through the Gateway