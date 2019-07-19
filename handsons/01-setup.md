# セットアップ

* **Mac の方** を前提とした手順となっています。
* Windows の方もVagrant+VirtualBox with 共有フォルダ の設定をベースに、同様の環境を作ってください。
  * ちなみに今回の後続のシステムプログラミング講座でやろうとしていることは、 **WSL1 ではできない** と聞いています（まず `/proc` がないそうです）
  * WSL2 はもしかしたら...と思うので、挑戦したらPRで内容反映をお願いしたいかも

## 作業用リポジトリのチェックアウトと更新をする

```console
$ git clone https://github.com/udzura/handsons.git; cd handsons
$ git pull --rebase origin master
```

* 以下、この `handsons` ディレクトリに入っての作業です

## Vagrant経由で開発マシンを立ち上げる

```console
$ vagrant up
```

* 今回のハンズオンに必要なパッケージは全部入ると思います。
  * めっちゃログでます。できれば事前にやっておいて欲しいです！
* 失敗しているようなら [Vagrantfile のセットアップスクリプト]() を眺めながらコマンドを打ち直してください

### 共有ディレクトリができてることを確認

```console
$ vagrant ssh
vagrant@ubuntu-bionic:~$ ls -l /vagrant
total 60
-rw-r--r-- 1 vagrant vagrant  1068 Jul 17 10:53 LICENSE
-rw-r--r-- 1 vagrant vagrant   102 Jul 19 05:43 README.md
-rw-r--r-- 1 vagrant vagrant  1165 Jul 19 07:54 Vagrantfile
-rw-r--r-- 1 vagrant vagrant  3008 Jul 19 07:37 Vagrantfile~
drwxr-xr-x 1 vagrant vagrant   128 Jul 19 08:01 handsons
-rw------- 1 vagrant vagrant 44584 Jul 19 08:03 ubuntu-bionic-18.04-cloudimg-console.log
...
```

## mrbgen-template コマンドをインストール

* Homebrew を入れてください。
  * https://brew.sh/index_ja
* Custom tapがあります。以下でインストール完了です。 <s>このTapは今日のために私が用意しました...</s>

```console
$ brew tap mrbgems/mrbgem-template
$ brew install mrbgem-template
```

* Windows の方はこのコマンドはLinux側に入れてください。

```console
$ cd /tmp
$ git clone https://github.com/matsumotory/mruby-mrbgem-template.git && \
  cd mruby-mrbgem-template && \
  rake && \
  sudo install mruby/bin/mrbgem-template /usr/local/bin
```

## mruby 自体のビルドができるかLinux上で確認

```console
$ cd /vagrant/workspace
$ git clone https://github.com/mruby/mruby.git
$ cd mruby
$ make
```

### mruby のバージョン確認とコード実行

```console
$ ./bin/mruby --version
mruby 2.0.1 (2019-04-04) 

$ ./bin/mruby -e "puts 'Hello, systems in depth'"
Hello, systems in depth
```

### mirb の立ち上げ

```console
$ ./bin/mirb
mirb - Embeddable Interactive Ruby Shell

> puts 'Hello, systems in depth!'
Hello, systems in depth!
 => nil
```

----

セットアップはここまでです！ お疲れ様でした :smily:

前日に準備されている方は、当日をお楽しみに〜
