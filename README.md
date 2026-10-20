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
curl localhost:3940          # Hello World
curl localhost:3940/health   # {"status":"UP"}
```

## 以 Docker 建置與執行

```bash
docker build -t spring-hello .
docker run --rm -p 3940:3940 spring-hello
curl localhost:3940          # Hello World
curl localhost:3940/health   # {"status":"UP"}
```

Dockerfile 分兩個階段：

1. `maven:3.9-eclipse-temurin-21`：下載依賴並編譯出 `app.jar`
2. `eclipse-temurin:21-jre-alpine`：只放 JRE 與 `app.jar`，映像檔較小

## Windows（Rancher Desktop，cmd）

Rancher Desktop 使用 containerd 引擎時，cmd 下沒有 `docker` 指令，請改用 `nerdctl`：

```bat
nerdctl build -t spring-hello .
nerdctl run --rm -p 3940:3940 spring-hello
```

另開一個 cmd 視窗呼叫（Windows 10 以後內建 `curl.exe`）：

```bat
curl localhost:3940
curl localhost:3940/health
```

進入容器使用 BusyBox：

```bat
nerdctl run --rm -it --entrypoint sh spring-hello
```

## 推送到 Azure Container Registry (ACR)

前置條件：已安裝 [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)，並已有（或可建立）一個 ACR。以下以 `<registry>` 代表 ACR 名稱（全小寫），`<resource-group>` 代表資源群組。

Windows cmd（Rancher Desktop，使用 `nerdctl`）：

```bat
:: 1. 登入 Azure
az login

:: 2. （可選）建立 ACR；已有可略過
az group create --name <resource-group> --location eastasia
az acr create --resource-group <resource-group> --name <registry> --sku Basic

:: 3. 取得 ACR 登入伺服器名稱（通常是 <registry>.azurecr.io）
az acr show --name <registry> --query loginServer --output tsv

:: 4. 以 access token 登入 ACR（nerdctl 不能用 az acr login，需手動登入）
az acr login --name <registry> --expose-token --output tsv --query accessToken > token.txt
set /p TOKEN=<token.txt
nerdctl login <registry>.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password %TOKEN%
del token.txt

:: 5. 標記並推送
nerdctl tag spring-hello <registry>.azurecr.io/spring-hello:1.0
nerdctl push <registry>.azurecr.io/spring-hello:1.0
```

說明：`az acr login` 預設是呼叫 `docker login`，在只有 `nerdctl` 的環境無法使用，因此改用 `--expose-token` 取得 token 後以 `nerdctl login` 登入。token 約 3 小時後失效，過期請重做第 4 步。也可改用 ACR 的 admin 帳號（需先 `az acr update -n <registry> --admin-enabled true`），但不建議用於正式環境。

驗證：

```bat
az acr repository list --name <registry> --output table
az acr repository show-tags --name <registry> --repository spring-hello --output table
```

## BusyBox

執行階段的 Alpine Linux 內建 BusyBox，可進入容器使用 `sh`、`ls`、`wget` 等指令：

```bash
docker run --rm -it --entrypoint sh spring-hello
busybox | head -3
```

## 容器內使用 curl 測試

runtime image 另外安裝了 `curl`，進入容器後可直接測試（容器內服務在 `localhost:3940`）：

```bash
# 對執行中的容器開 shell（Rancher Desktop containerd 用 nerdctl，dockerd 用 docker）
nerdctl exec -it <容器名稱或ID> sh

# 在容器內
curl localhost:3940
curl localhost:3940/health   # {"status":"UP"}
```

## API

| Method | Path | 回應        |
| ------ | ---- | ----------- |
| GET    | `/`  | Hello World |
| GET    | `/health` | `{"status":"UP"}` |
