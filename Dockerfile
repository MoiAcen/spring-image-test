# ---- build stage ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q package -DskipTests

# ---- runtime stage ----
# Alpine Linux 內建 BusyBox (sh, ls, wget ...)，可直接 `docker exec -it <container> sh`
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /workspace/target/app.jar app.jar
EXPOSE 3940
ENTRYPOINT ["java", "-jar", "app.jar"]
