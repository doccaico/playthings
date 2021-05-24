## Flask-BBS

昔風の掲示板。

- メールはSendGridを使わずGmailを使用
  - 注意: [Gmailアカウントで「安全性の低いアプリのアクセス」を許可](https://myaccount.google.com/security)する必要がある
- ページャー
- 管理画面

<img src="https://github.com/doccaico/playthings/blob/main/python/flask-bbs/screenshot/0.png?raw=true" width="400" height="300"><img src="https://github.com/doccaico/playthings/blob/main/python/flask-bbs/screenshot/1.png?raw=true" width="400" height="300">

### バージョンと使用ライブラリ

- Python 3.7.3

+ [Flask ][flask]
+ [Flask-Admin][flaskadmin]
+ [Flask-Login][flasklogin]
+ [Flask-Paginate][flaskpaginate]
+ [Flask-Sqlalchemy][flasksqlalchemy]

- デプロイ先 [HEROKU][heroku]

### 環境設定 (miniconda)

```
$ conda create -n flask-bbs python=3.7.3
$ conda activate flask-bbs

$ cd flask-bbs
$ pip -r requirements.txt
```


## ローカル (dev)

### データベースのインストール(PostgreSQL)

```
# debian系

$ apt install postgresql
```

### テーブル作成とダミーデータ追加


```
$ createdb flask_bbs_db
$ psql -d flask_bbs_db -f flask_bbs/utils/init_db.sql
```

### 実行スクリプトを作成

```
# run.sh
export FLASK_ENV="development"
export APP_SETTINGS="flask_bbs.config.DevelopmentConfig"
export FLASK_BBS_GMAIL_ADDRESS= "*******"
export FLASK_BBS_GMAIL_PASSWORD="*******"
export FLASK_APP=flask_bbs

flask run
```

## デプロイ

### タイムゾーン

```
$ heroku config:add TZ=Asia/Tokyo -a [your_app_name]
```

### データベースのインストール(Heroku PostgreSQL)

```
$ heroku addons:create heroku-postgresql:hobby-dev
```

### テーブル作成とダミーデータ追加

```
$ heroku pg:psql -a [your_app_name] \
      -f flask_bbs/utils/init_db.sql
```

### 環境変数の設定

```
$ heroku config:set \
      APP_SETTINGS="flask_bbs.config.ProductionConfig" \
      FLASK_BBS_GMAIL_ADDRESS= "*******" \
      FLASK_BBS_GMAIL_PASSWORD="*******" \
      SQLALCHEMY_DATABASE_URI="$(heroku config:get DATABASE_URL)"\
      SECRET_KEY="*************"
```

### 動かしてみる

```
# push
$ git push heroku master

# 起動
$ heroku ps:scale web=1

# 確認
# Dynos:          web: 1 ならOK
$ heroku apps:info
=== beachleavings
Addons:         heroku-postgresql:hobby-dev
Auto Cert Mgmt: false
Dynos:          web: 1
Git URL:        https://git.heroku.com/beachleavings.git
Owner:          example@gmail.com
Region:         us
Repo Size:      317 KB
Slug Size:      53 MB
Stack:          heroku-18
Web URL:        https://beachleavings.herokuapp.com/
```

[heroku]: https://id.heroku.com
[flask]: https://github.com/pallets/flask
[flaskadmin]: https://github.com/flask-admin/flask-admin
[flasklogin]: https://github.com/maxcountryman/flask-login
[flaskpaginate]: https://github.com/lixxu/flask-paginate
[flasksqlalchemy]: https://github.com/pallets/flask-sqlalchemy/
