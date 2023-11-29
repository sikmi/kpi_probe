
# docker-composeでの起動
以下の環境変数が必要です。
ルートディレクトリに`.env`ファイルを作成してください。
```
RDS_HOSTNAME=xxx-db-1.external.group  # dockerネットワーク内(後述)の計測対象アプリケーション用DBに接続
RDS_USERNAME=user                     # 計測対象アプリケーション用DBのユーザー
RDS_PASSWORD=password                 # 計測対象アプリケーション用DBのパスワード
RDS_DB_NAME=xxx_production            # 計測対象アプリケーション用DB名
USER_TABLE=users                      # 計測対象アプリuserテーブルの名前を指定。デフォルト: 'users'
USER_NAME_ATTRIBUTE=name              # 計測対象アプリuserの表示名カラムを指定。デフォルト: 'name'
```
計測対象アプリケーションのユーザーデータを参照するため、ユーザーにあたるテーブル名とユーザー名にあたるカラム名を設定してください。
