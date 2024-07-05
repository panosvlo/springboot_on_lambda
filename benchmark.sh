#bin/sh

app=$1

if [ $app == "spring" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output.json | jq -r '.UnicornStoreSpringApp.ApiEndpointSpring') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml
  exit 0
fi


if [ $app == "spring-graalvm" ]
then
  artillery run -t $(cat infrastructure/cdk/target/output-spring-graalvm.json | jq -r '.UnicornStoreSpringGraalVMApp.ApiEndpointSpringGraalVM') -v '{ "url": "/unicorns" }' infrastructure/loadtest.yaml
  exit 0
fi


