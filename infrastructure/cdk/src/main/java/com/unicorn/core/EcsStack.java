package com.unicorn.core;

import software.amazon.awscdk.*;
import software.amazon.awscdk.services.ecs.Cluster;
import software.amazon.awscdk.services.ecs.ContainerDefinitionOptions;
import software.amazon.awscdk.services.ecs.FargateTaskDefinition;
import software.amazon.awscdk.services.ecs.ContainerDefinition;
import software.amazon.awscdk.services.ecs.PortMapping;
import software.amazon.awscdk.services.ecs.patterns.ApplicationLoadBalancedFargateService;
import software.amazon.awscdk.services.ecs.ContainerImage;
import software.constructs.Construct;
import software.amazon.awscdk.services.iam.ServicePrincipal;
import software.amazon.awscdk.services.iam.Role;
import software.amazon.awscdk.services.ecs.AwsLogDriver;
import software.amazon.awscdk.services.ecs.AwsLogDriverMode;
import software.amazon.awscdk.services.iam.ManagedPolicy;
import software.amazon.awscdk.services.iam.PolicyStatement;
import software.amazon.awscdk.services.iam.Effect;
import software.amazon.awscdk.services.elasticloadbalancingv2.HealthCheck;


import java.util.Map;
import java.util.List;

public class EcsStack extends Stack {

    public EcsStack(final Construct scope, final String id, final StackProps props, final InfrastructureStack infrastructureStack) {
        super(scope, id, props);

        // Get account ID and region from the stack context
        String accountId = Stack.of(this).getAccount();
        String region = Stack.of(this).getRegion();

        // Create an ECS cluster
        Cluster cluster = Cluster.Builder.create(this, "EcsCluster")
                .vpc(infrastructureStack.getVpc())
                .build();

        Role executionRole = Role.Builder.create(this, "FargateContainerRole")
                .assumedBy(new ServicePrincipal("ecs-tasks.amazonaws.com"))
                .managedPolicies(List.of(ManagedPolicy.fromAwsManagedPolicyName("service-role/AmazonECSTaskExecutionRolePolicy")))
                .build();


        // Create a Fargate task definition
        FargateTaskDefinition taskDefinition = FargateTaskDefinition.Builder.create(this, "TaskDef")
                .memoryLimitMiB(2048)
                .cpu(1024)
                .executionRole(executionRole)
                .build();

        // Add container to the task definition
        ContainerDefinition UnicornStoreContainer = taskDefinition.addContainer("UnicornStoreContainer", ContainerDefinitionOptions.builder()
                .image(ContainerImage.fromRegistry(accountId + ".dkr.ecr." + region + ".amazonaws.com/unicorn-store-repo:latest"))
                .memoryLimitMiB(2048)
                .environment(Map.of(
                        "SPRING_DATASOURCE_PASSWORD", infrastructureStack.getDatabaseSecretString(),
                        "SPRING_DATASOURCE_URL", infrastructureStack.getDatabaseJDBCConnectionString()
                ))
                .logging(AwsLogDriver.Builder.create().streamPrefix("unicorn-store-ecs").mode(AwsLogDriverMode.NON_BLOCKING).build())
                .build());

        PortMapping portMapping = PortMapping.builder()
                .containerPort(8080)
                .build();

        UnicornStoreContainer.addPortMappings(portMapping);

        // Create an Application Load Balanced Fargate Service
        ApplicationLoadBalancedFargateService fargateService = ApplicationLoadBalancedFargateService.Builder.create(this, "FargateService")
                .cluster(cluster)
                .taskDefinition(taskDefinition)
                .desiredCount(1)
                .publicLoadBalancer(true)
                .listenerPort(80)
                .build();

        fargateService.getTargetGroup().configureHealthCheck(new HealthCheck.Builder()
                .path("/actuator/health")
                .port("8080")
                .interval(Duration.seconds(125))
                .timeout(Duration.seconds(120))
                .healthyThresholdCount(2)
                .unhealthyThresholdCount(2)
                .build());


        // Output the load balancer URL
        new CfnOutput(this, "LoadBalancerDNS", CfnOutputProps.builder()
                .value("http://" + fargateService.getLoadBalancer().getLoadBalancerDnsName())
                .build());
    }
}
