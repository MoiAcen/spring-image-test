# spring-image-test

最簡單的 Spring Boot Hello World，可直接 build 成 Docker image。
Runtime image 為 Alpine Linux（內含 BusyBox）+ JRE 21。

```bash
docker build -t spring-hello .
docker run --rm -p 8080:8080 spring-hello
curl localhost:8080          # Hello World

# 進入容器使用 busybox
docker run --rm -it --entrypoint sh spring-hello -c "busybox | head -3"
```
