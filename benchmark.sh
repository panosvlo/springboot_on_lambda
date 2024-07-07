#bin/sh

app=$1

if [ $app == "spring-lambda" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output.json | jq -r '.UnicornStoreSpringApp.ApiEndpointSpring') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml
  exit 0
fi


if [ $app == "spring-graalvm" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output-spring-graalvm.json | jq -r '.UnicornStoreSpringGraalVMApp.ApiEndpointSpringGraalVM') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml
  exit 0
fi


if [ $app == "spring-lambda-snapstart" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output-spring-lambda-snapstart.json | jq -r '.UnicornStoreSpringLambdaSnapstart.ApiEndpointSpringLambdaSnapstart') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml
  exit 0
fi

if [ $app == "spring-lambda-ecs" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output-spring-ecs.json | jq -r '.UnicornStoreEcsStack.LoadBalancerDNS') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml
  exit 0
fi


