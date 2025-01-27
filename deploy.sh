#bin/sh

app=$1
build=$2

if [ $app == "spring-lambda" ]
then
  if [[ $build == "--build" ]]
  then
    ./mvnw clean package -f software/unicorn-store-spring-lambda/pom.xml
  fi
  cd infrastructure/cdk
  cdk deploy UnicornStoreSpringApp --outputs-file target/output.json --require-approval never
  exit 0
fi

if [ $app == "spring-graalvm" ]
then
  if [[ $build == "--build" ]]
  then
    ./mvnw clean package -f software/alternatives/unicorn-store-basic/pom.xml
  fi
  cd infrastructure/cdk
  cdk deploy UnicornStoreSpringGraalVMApp --outputs-file target/output-spring-graalvm.json --require-approval never
  exit 0
fi

if [ $app == "spring-lambda-snapstart" ]
then
  if [[ $build == "--build" ]]
  then
    ./mvnw clean package -f software/unicorn-store-spring-lambda/pom.xml
  fi
  cd infrastructure/cdk
  cdk deploy UnicornStoreSpringLambdaSnapstart --outputs-file target/output-spring-lambda-snapstart.json --require-approval never
  exit 0
fi

