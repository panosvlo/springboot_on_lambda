# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim

# The application's jar file
ARG JAR_FILE=target/store-spring*.jar

# Add the application's jar to the container
COPY ${JAR_FILE} app.jar

# Run the jar file
ENTRYPOINT ["java","-jar","/app.jar"]
