# mrbgem を作る

* mgemのコードは作業用リポジトリの `./workspace` の下に作ってください！共有フォルダの関係です。
* このmarkdownでの手順は、 `<on Mac>` `<on Linux>` に分かれます。それぞれターミナルを分けておくのがオススメ

## できればするといいこと

* git の以下の設定を入れておくと、 `mrbgem-template` コマンドがいい感じに動きます

```console
$ git config --global github.user udzura
$ git config --global user.name "Uchio Kondo"
```

## 1) 負荷を取得するmgemを作る

### Making a boilerplate

```console
### <on Mac>
$ cd workspace/
$ mrbgem-template mruby-loadavg
Generate all files of mruby-loadavg
create dir : ./mruby-loadavg
create dir : ./mruby-loadavg/src
...
```

以下のようなファイル構成になります。CRubyのgemよりちょっと少ないかな？

```
mruby-loadavg
├── LICENSE
├── README.md
├── Rakefile
├── mrbgem.rake
├── mrblib
│   └── mrb_loadavg.rb
├── mruby-loadavg.gem
├── src
│   ├── mrb_loadavg.c
│   └── mrb_loadavg.h
└── test
    └── mrb_loadavg.rb

3 directories, 9 files
```

今回は `src` ディレクトリは **不要なので** 削除しちゃっていいです。

```console
### <on Mac>
$ cd mruby-loadavg
$ rm -rf src/
```

また、 `mrbgem.rake` で依存する外部もしくは標準添付のmgemを指定します。今回は `File` クラスが定義されている `mruby-io` mgemが必要そうですね。

```ruby
MRuby::Gem::Specification.new('mruby-loadavg') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Uchio Kondo'

  spec.add_dependency 'mruby-io'
end
```

### ビルドできるかだけ試しておきましょう

```console
### <on Linux>
$ cd /vagrant/workspace/mruby-loadavg
$ rake
$ ./mruby/bin/mirb 
mirb - Embeddable Interactive Ruby Shell

> Loadavg.class
 => Class
```

### ここまでできたら、 `mrblib` の下にあるRubyスクリプトに、いつものようにRubyを書けばOKです。

* エディタはMac側で立ち上げて編集すると楽かな？
* rbファイルを追加すればそれも勝手に認識してくれます。

### 実装のヒント

* `/proc/loadavg` というファイルを読み込めばOKです
  * こういうフォーマットになります
  * ただのファイルとして開いて、読み取り、splitすれば良さそう

```console
### <on Linux>
$ cat /proc/loadavg 
0.07 0.12 0.11 1/140 22587
```

* しかし、それぞれの数字の意味はなんでしょう？
  * [man があります](https://linuxjm.osdn.jp/html/LDP_man-pages/man5/proc.5.html)
  * シスプロを始めると man のセクション1以外を見るようになります :)
* 実装したら、 `rake && mirb` を繰り返し、Loadavgが取得できているか確認しつつ進めましょう

### Publish the mgem

* GitHub に個人のアカウントに紐づけて `mruby-***` というリポジトリを作り、pushすれば完了です。
* さっきの mrbgem-template で作ったプロジェクトを Git リポジトリ化しておきましょう。

```console
### <on Mac>
$ cd workspace/mruby-loadavg
$ git init .
$ git add . ; git status
$ git commit
$ git remote add origin git@github.com:udzura/mruby-loadavg.git
$ git push origin master
```

### 実装例

* @udzura の実装例を [作業用リポジトリ]() に置いてあるので眺めてください。
