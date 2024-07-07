#bin/sh

app=$1

if [ $app == "spring-lambda" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output.json | jq -r '.UnicornStoreSpringApp.ApiEndpointSpring') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml --output artillery-lambda.json
  artillery report artillery-lambda.json
  exit 0
fi

if [ $app == "spring-lambda-snapstart" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output-spring-lambda-snapstart.json | jq -r '.UnicornStoreSpringLambdaSnapstart.ApiEndpointSpringLambdaSnapstart') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml --output artillery-lambda-snapstart.json
  artillery report artillery-lambda-snapstart.json
  exit 0
fi

if [ $app == "spring-ecs" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output-spring-ecs.json | jq -r '.UnicornStoreEcsStack.LoadBalancerDNS') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml --output artillery-ecs.json
  artillery report artillery-ecs.json
  exit 0
fi


