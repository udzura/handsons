# セットアップ

* **Mac の方** を前提とした手順となっています。
* Windows の方もVagrant+VirtualBox with 共有フォルダ の設定をベースに、同様の環境を作ってください。
  * ちなみに今回の後続のシステムプログラミング講座でやろうとしていることは、 **WSL1 ではできない** と聞いています（まず `/proc` がないそうです）
  * WSL2 はもしかしたら...と思うので、挑戦したらPRで内容反映をお願いしたいかも
* このmarkdownでの手順は、 `<on Mac>` `<on Linux>` に分かれます。それぞれターミナルを分けておくのがオススメ

## ツールのインストール

* Vagrant
  * https://www.vagrantup.com/downloads.html の「macOS 64-bit」よりどうぞ
* VirtualBox
  * https://www.virtualbox.org/wiki/Downloads の「OS X hosts」よりどうぞ
* どちらもdmgが配られています
* バージョンによっては MacOS の セキュリティ周りの設定でハマるようです。
  * 「開発元”Oracle America, Inc.”のシステム・ソフトウェアの読み込みがブロックされました〜」のようなメッセージが出るそうです
  * https://qiita.com/ksyunnnn/items/2884516bf333c536a9cb Qiita で言えばこのあたりの記事だと思います

## 作業用リポジトリのチェックアウトと更新をする

```console
### <on Mac>
$ git clone https://github.com/udzura/handsons.git; cd handsons
$ git pull --rebase origin master
```

* 以下、この `handsons` ディレクトリに入っての作業です

## Vagrant経由で開発マシンを立ち上げる

```console
### <on Mac>
$ vagrant plugin install vagrant-disksize # 必要なプラグイン
$ vagrant up
```

* 今回のハンズオンに必要なパッケージは全部入ると思います。
  * めっちゃログでます。できれば事前にやっておいて欲しいです！
* 失敗しているようなら [Vagrantfile のセットアップスクリプト](https://github.com/udzura/handsons/blob/master/Vagrantfile#L21-L30) を眺めながらコマンドを打ち直してください

### 共有ディレクトリができてることを確認

```console
### <on Mac>
$ vagrant ssh

### <on Linux>
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

## mrbgem-template コマンドをインストール

* Mac 側に Homebrew を入れてください。
  * https://brew.sh/index_ja
* Custom tapがあります。以下でインストール完了です。 <s>このTapは今日のために私が用意しました...</s>

```console
### <on Mac>
$ brew tap mrbgems/mrbgem-template
$ brew install mrbgem-template
$ mrbgem-template --help
Usage: mrbgem-template [options] mrbgem_name
    -h, --help                       Show usage
    -v, --version                    Show version
    -l, --license [LICENSE]          Set license
    -u, --github-user [USER]         Set user name on github
    -p, --mrbgem-prexif [PREFIX]     Set prefix dir to mgem project
    -c, --class-name [CLASS]         Set class name
    -a, --author [AUTHOR]            Set the author of this mgem
    -b, --[no-]local-builder         Enable or disable local builder
    -C, --[no-]ci                    Enable or disable CI by travis
```

* Windows の方はこのコマンドはLinux側に入れてください。

```console
### <on Linux>
$ cd /tmp
$ git clone https://github.com/matsumotory/mruby-mrbgem-template.git && \
  cd mruby-mrbgem-template && \
  rake && \
  sudo install mruby/bin/mrbgem-template /usr/local/bin
```

## mruby 自体のビルドができるかLinux上で確認

```console
### <on Linux>
$ cd /vagrant/workspace
$ git clone https://github.com/mruby/mruby.git
$ cd mruby
$ make
```

### mruby のバージョン確認とコード実行

```console
### <on Linux>
$ ./bin/mruby --version
mruby 2.0.1 (2019-04-04) 

$ ./bin/mruby -e "puts 'Hello, systems in depth'"
Hello, systems in depth
```

### mirb の立ち上げ

```console
### <on Linux>
$ ./bin/mirb
mirb - Embeddable Interactive Ruby Shell

> puts 'Hello, systems in depth!'
Hello, systems in depth!
 => nil
```

----

セットアップはここまでです！ お疲れ様でした :smily:

前日に準備されている方は、当日をお楽しみに〜

## トラブルシュート

### `vagrant-disksize` が入らない

* `vagrant-vbguest` を先に入れるとうまくいくかもしれません

```console
$ vagrant plugin install vagrant-vbguest
```

### Boxの容量が妙に少ない

```console
vagrant@ubuntu-bionic:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            2.0G     0  2.0G   0% /dev
tmpfs           395M  5.9M  389M   2% /run
/dev/sda1       2.2G  2.1G   68M  97% /
tmpfs           2.0G     0  2.0G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
/dev/loop0       89M   89M     0 100% /snap/core/7270
/dev/loop1       98M   98M     0 100% /snap/docker/384
vagrant         466G  401G   66G  86% /vagrant
tmpfs           395M     0  395M   0% /run/user/1000
```

* `resize2fs` コマンドを使うと拡張されるかもしれない

```console
vagrant@ubuntu-bionic:~$ sudo resize2fs /dev/sda1
resize2fs 1.43.8 (1-Jan-2018)
Filesystem at /dev/sda1 is mounted on /; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 2
The filesystem on /dev/sda1 is now 2621179 (4k) blocks long.
```
