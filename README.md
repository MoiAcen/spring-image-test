# spring-image-test

最簡單的 Spring Boot Hello World，可直接 build 成 Docker image。
Runtime image 為 Alpine Linux（內含 BusyBox）+ JRE 21。

## 技術棧

- Spring Boot 3.3.5
- Java 21
- Maven 3.9
- Docker（多階段建置，執行階段為 `eclipse-temurin:21-jre-alpine`）

## 專案結構

```
.
├── Dockerfile
├── pom.xml
└── src/main/java/com/example/hello/HelloApplication.java
```

## 本機執行（不使用 Docker）

需要 JDK 21 與 Maven。

```bash
mvn package -DskipTests
java -jar target/app.jar
curl localhost:8080          # Hello World
```

## 以 Docker 建置與執行

```bash
docker build -t spring-hello .
docker run --rm -p 8080:8080 spring-hello
curl localhost:8080          # Hello World
```

Dockerfile 分兩個階段：

1. `maven:3.9-eclipse-temurin-21`：下載依賴並編譯出 `app.jar`
2. `eclipse-temurin:21-jre-alpine`：只放 JRE 與 `app.jar`，映像檔較小

## BusyBox

執行階段的 Alpine Linux 內建 BusyBox，可進入容器使用 `sh`、`ls`、`wget` 等指令：

```bash
docker run --rm -it --entrypoint sh spring-hello
busybox | head -3
```

## API

| Method | Path | 回應        |
| ------ | ---- | ----------- |
| GET    | `/`  | Hello World |
