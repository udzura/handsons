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

## upstreamをホスト名から動的に変更する

### 事前準備

* 事前準備でそもそものupstreamを用意します。今回は、ホスト名にapacheが入ってたらapache、nginxが入っていたらnginxのサーバを返すものを作ります。
* 今回は8081番にapache、8082番にnginxです。お好みでお好きなコンテンツをあげてください。

```console
$ sudo docker run -ti -d -p8081:80 httpd:2.4
$ sudo docker run -ti -d -p8082:80 nginx:1.16
```

### Nginx側の設定

* `mruby_set` で$backendを動的にセットしているのがわかると思います。他はNginxをプロクシとして使うときのおまじないみたいな...。

```conf
...
    server {
        listen       80;
        server_name  localhost;
        location / {
            resolver              8.8.8.8;
            mruby_set $backend    mruby/step1.rb

            proxy_http_version    1.1;
            proxy_pass            http://$backend;
            proxy_set_header      Host $host;
            proxy_set_header      Connection "";
            proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header      X-Forwarded-Host $host;
            proxy_set_header      X-Forwarded-Server $host;
            proxy_set_header      X-Real-IP $remote_addr;
            # root   html;
            # index  index.html index.htm;
        }
    }
```

### mruby の配置

* `/usr/local/nginx-mruby/mruby/*.rb` にmrubyスクリプトをおきましょう。今回はこちら

```ruby
data = Nginx::Var.new
domain = data.http_host
upstream = ""

case domain
when /apache/
  upstream = "127.0.0.1:8081"
when /nginx/
  upstream = "127.0.0.1:8082"
else
end

upstream
```

* 何をしているのか、帰るにはどうすればいいか、Rubyなので大変わかりやすい。
* 最後に評価された値が変数にセットされます。

### これで立ち上げる

* port forward してるはずなのでホストから
  * `http://apache.127.0.0.1.xip.io:8080/`
  * `http://nginx.127.0.0.1.xip.io:8080/`
  * `http://udzura.127.0.0.1.xip.io:8080/`
* へのアクセスを確認して見ましょう。
* 宿題として、「その他」の場合に今は503になってしまうのを、もっといい感じにできないか考えてみましょう

## 設定例について

* このレポジトリの `ngx_mruby/` ディレクトリに設定の実際の例を置いています。mrubyスクリプトを含む。
