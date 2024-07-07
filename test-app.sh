#bin/sh

app=$1

if [ $app == "spring-lambda" ]
then
  curl --location --request POST $(cat infrastructure/cdk/target/output.json | jq -r '.UnicornStoreSpringApp.ApiEndpointSpring')'/unicorns' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "Something",
    "age": "Older",
    "type": "Animal",
    "size": "Very big"
}' | jq

  exit 0
fi


if [ $app == "spring-graalvm" ]
then
    curl --location --request POST $(cat infrastructure/cdk/target/output-spring-graalvm.json | jq -r '.UnicornStoreSpringGraalVMApp.ApiEndpointSpringGraalVM')'/unicorns' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "Something",
    "age": "Older",
    "type": "Animal",
    "size": "Very big"
}' | jq

  exit 0
fi


if [ $app == "spring-lambda-snapstart" ]
then
    curl --location --request POST $(cat infrastructure/cdk/target/output-spring-lambda-snapstart.json | jq -r '.UnicornStoreSpringLambdaSnapstart.ApiEndpointSpringLambdaSnapstart')'/unicorns' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "Something",
    "age": "Older",
    "type": "Animal",
    "size": "Very big"
}' | jq

  exit 0
fi

if [ $app == "spring-ecs" ]
then
    curl --location --request POST $(cat infrastructure/cdk/target/output-spring-ecs.json | jq -r '.UnicornStoreEcsStack.LoadBalancerDNS')'/unicorns' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "Something",
    "age": "Older",
    "type": "Animal",
    "size": "Very big"
}' | jq

  exit 0
fi



