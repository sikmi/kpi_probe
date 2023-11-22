# dockerネットワークの設定
本アプリケーションとMatomoから計測対象のアプリケーションDBに接続するために必要な設定です。
dockerネットワークを使用してDBへの接続を行います。
計測アプリケーションの`docker-compose.yml`へ以下の設定を追加して下さい。

```yml
services:
  db:
    # DBコンテナの設定に以下を追加
    networks:
      - external.group
      - default
```

```yml
# ルートの設定に以下を追加
networks:
  external.group:
    external: true
```
以下のコマンドでネットワークを作成
```sh
$ docker network create external.group 
```
ネットワークが作成されているか確認


```sh
$ docekr network ls

=> 
NETWORK ID     NAME                               DRIVER    SCOPE
xxxxxxxxxxxx   external.group                     bridge    local
```
