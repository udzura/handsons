# ngx_mruby を触る

* このmarkdownでの手順は、 `<on Mac>` `<on Linux>` に分かれます。それぞれターミナルを分けておくのがオススメ

## ビルドする

```console
### <on Linux>
$ cd ~
$ git clone https://github.com/matsumotory/ngx_mruby.git
$ cd ngx_mruby
$ vim build_config.rb
```

* 設定である `build_config.rb` を以下のように編集する

```ruby
## L32 松本さんのmruby-uname を使わないならコメントアウト
# conf.gem :github => 'matsumotory/mruby-uname'

...
## L59 以降 end までの間に、今回使うmgemを指定する
  conf.gem github: "udzura/mruby-loadavg"
  conf.gem github: "udzura/mruby-uname"
end
```

* その後ビルド

```console
### <on Linux>
$ env NGINX_CONFIG_OPT_ENV='--prefix=/usr/local/nginx-mruby' sh ./build.sh
...
build successful
$ sudo make install
...
$ /usr/local/nginx-mruby/sbin/nginx -V
nginx version: nginx/1.17.1
built by gcc 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1) 
configure arguments: --add-module=/home/vagrant/ngx_mruby --add-module=/home/vagrant/ngx_mruby/dependence/ngx_devel_kit --prefix=/usr/local/nginx-mruby
```

* 参考: https://github.com/matsumotory/ngx_mruby/tree/master/docs/install#installing-from-source

## Hello world

```
$ sudo vi /usr/local/nginx-mruby/conf/nginx.conf
```

* conf を以下に編集

```
...
    server {
        listen       80;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }

        # この下を追加
        location /mruby {
            mruby_content_handler_code '
              Nginx.rputs "Hello #{Nginx.module_name}/#{Nginx.module_version} world!\n"
            ';
        }
....
```

### 起動と確認

```console
$ sudo /usr/local/nginx-mruby/sbin/nginx
$ curl localhost/mruby
Hello ngx_mruby/2.1.4 world!
```

### 停止（雑です）

```console
$ sudo killall nginx
```

## 設定例について

* このレポジトリの `ngx_mruby/` ディレクトリに設定の実際の例を置いています。
