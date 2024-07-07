package com.unicorn.alternatives;

import com.unicorn.core.InfrastructureStack;
import software.amazon.awscdk.*;
import software.amazon.awscdk.services.apigateway.LambdaRestApi;
import software.amazon.awscdk.services.apigateway.RestApi;
import software.amazon.awscdk.services.lambda.Code;
import software.amazon.awscdk.services.lambda.Function;
import software.amazon.awscdk.services.lambda.Runtime;
import software.constructs.Construct;
import software.amazon.awscdk.services.lambda.SnapStartConf;
import software.amazon.awscdk.services.lambda.Version;

import java.util.List;
import java.util.Map;

public class UnicornStoreSpringLambdaSnapstart extends Stack {

    private final InfrastructureStack infrastructureStack;

    public UnicornStoreSpringLambdaSnapstart(final Construct scope, final String id, final StackProps props, final InfrastructureStack infrastructureStack) {
        super(scope, id, props);
        this.infrastructureStack = infrastructureStack;

        var UnicornStoreSpringLambdaSnapstart = createUnicornLambdaFunction();
        infrastructureStack.getEventBridge().grantPutEventsTo(UnicornStoreSpringLambdaSnapstart);

        var restApi = setupRestApi(UnicornStoreSpringLambdaSnapstart);

        new CfnOutput(this, "ApiEndpointSpringLambdaSnapstart", CfnOutputProps.builder()
                .value(restApi.getUrl())
                .build());

        //Create output values for later reference
        new CfnOutput(this, "unicorn-store-spring-snapstart-function-arn", CfnOutputProps.builder()
                .value(UnicornStoreSpringLambdaSnapstart.getFunctionArn())
                .build());
    }

    private RestApi setupRestApi(Version UnicornStoreSpringLambdaSnapstart) {
        return LambdaRestApi.Builder.create(this, "UnicornStoreSpringLambdaSnapstartApi")
                .restApiName("UnicornStoreSpringLambdaSnapstartApi")
                .handler(UnicornStoreSpringLambdaSnapstart)
                .build();
    }

    private Version createUnicornLambdaFunction() {
        var lambda =  Function.Builder.create(this, "UnicornStoreSpringSnapstartFunction")
                .runtime(Runtime.JAVA_21)
                .functionName("unicorn-store-spring-lambda-snapstart")
                .memorySize(2048)
                .timeout(Duration.seconds(29))
                .code(Code.fromAsset("../../software/unicorn-store-spring-lambda/target/store-spring-lambda-1.0.0.jar"))
                .handler("com.amazonaws.serverless.proxy.spring.SpringDelegatingLambdaContainerHandler")
                .vpc(infrastructureStack.getVpc())
                .securityGroups(List.of(infrastructureStack.getApplicationSecurityGroup()))
                .environment(Map.of(
                        "MAIN_CLASS", "com.unicorn.store.lambda.StoreApplication",
                        "SPRING_DATASOURCE_PASSWORD", infrastructureStack.getDatabaseSecretString(),
                        "SPRING_DATASOURCE_URL", infrastructureStack.getDatabaseJDBCConnectionString(),
                        "SPRING_DATASOURCE_HIKARI_maximumPoolSize", "1",
                        "AWS_SERVERLESS_JAVA_CONTAINER_INIT_GRACE_TIME", "250"
                ))
                //Add below to enable SnapStart. Comment it to disable SnapStart
                .snapStart(SnapStartConf.ON_PUBLISHED_VERSIONS)
                .build();

        // Return version
        return lambda.getCurrentVersion();
    }

}
